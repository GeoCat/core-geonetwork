/*
 * Copyright (C) 2001-2026 Food and Agriculture Organization of the
 * United Nations (FAO-UN), United Nations World Food Programme (WFP)
 * and United Nations Environment Programme (UNEP)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 *
 * Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
 * Rome - Italy. email: geonetwork@osgeo.org
 */

package org.fao.geonet.api.records;

import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Hit;
import co.elastic.clients.json.JsonData;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import jeeves.server.context.ServiceContext;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.text.StringEscapeUtils;
import org.fao.geonet.ApplicationContextHolder;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.NodeInfo;
import org.fao.geonet.api.API;
import org.fao.geonet.api.es.EsHTTPProxy;
import org.fao.geonet.api.records.model.related.AssociatedRecord;
import org.fao.geonet.api.records.model.related.RelatedItemOrigin;
import org.fao.geonet.api.records.model.related.RelatedItemType;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.AbstractMetadata;
import org.fao.geonet.domain.ReservedOperation;
import org.fao.geonet.domain.Source;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.SchemaManager;
import org.fao.geonet.kernel.datamanager.IMetadataValidator;
import org.fao.geonet.kernel.datamanager.base.BaseMetadataUtils;
import org.fao.geonet.kernel.schema.AssociatedResource;
import org.fao.geonet.kernel.schema.AssociatedResourcesSchemaPlugin;
import org.fao.geonet.kernel.schema.SchemaPlugin;
import org.fao.geonet.kernel.search.EsSearchManager;
import org.fao.geonet.kernel.setting.SettingInfo;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.lib.Lib;
import org.fao.geonet.repository.MetadataValidationRepository;
import org.fao.geonet.repository.SourceRepository;
import org.fao.geonet.repository.specification.MetadataValidationSpecs;
import org.fao.geonet.utils.Log;
import org.fao.geonet.utils.Xml;
import org.jdom.Content;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.output.DOMOutputter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.ApplicationContext;
import org.w3c.dom.Node;

import java.util.*;
import java.util.stream.Collectors;

import static org.fao.geonet.kernel.search.EsFilterBuilder.buildPermissionsFilter;
import static org.fao.geonet.kernel.search.EsSearchManager.*;


/**
 *
 */
public class MetadataUtils {
    public static final boolean FOR_EDITING = false;
    public static final boolean WITH_VALIDATION_ERRORS = false;
    public static final boolean KEEP_XLINK_ATTRIBUTES = false;

    private static final Logger LOGGER = LoggerFactory.getLogger(Geonet.SEARCH_ENGINE);

    public static class RelatedTypeDetails {
        private String query;
        private Set<String> expectedRecords = new HashSet<>();
        private Set<String> remoteRecords = new HashSet<>();
        private Map<String, Map<String, String>> recordsProperties = new HashMap<>();

        public RelatedTypeDetails(String query) {
            this.query = query;
        }
        public RelatedTypeDetails(String query, Set<String> expectedRecords) {
            this.query = query;
            this.expectedRecords = expectedRecords;
        }
        public RelatedTypeDetails(String query, Set<String> expectedRecords, Map<String, Map<String, String>> recordsProperties) {
            this.query = query;
            this.expectedRecords = expectedRecords;
            this.recordsProperties = recordsProperties;
        }

        public RelatedTypeDetails(String query, Set<String> expectedRecords, Map<String, Map<String, String>> recordsProperties, Set<String> remoteRecords) {
            this.query = query;
            this.expectedRecords = expectedRecords;
            this.recordsProperties = recordsProperties;
            this.remoteRecords = remoteRecords;
        }

        public String getQuery() {
            return query;
        }

        public void setQuery(String query) {
            this.query = query;
        }

        public Set<String> getExpectedRecords() {
            return expectedRecords;
        }

        public void setExpectedRecords(Set<String> expectedRecords) {
            this.expectedRecords = expectedRecords;
        }

        public Map<String, Map<String, String>> getRecordsProperties() {
            return recordsProperties;
        }

        public void setRecordsProperties(Map<String, Map<String, String>> recordsProperties) {
            this.recordsProperties = recordsProperties;
        }

        public Set<String> getRemoteRecords() {
            return remoteRecords;
        }
    }


    public static Node getAssociatedAsXml(String metadataUuid) {
        Element relations = new Element("relations");
        BaseMetadataUtils metadataUtils = ApplicationContextHolder.get().getBean(BaseMetadataUtils.class);
        AbstractMetadata metadataEntity = metadataUtils.findOneByUuid(metadataUuid);

        ServiceContext context = ServiceContext.get();


        try {
            Map<RelatedItemType, List<AssociatedRecord>> associated = MetadataUtils.getAssociated(context, metadataEntity, RelatedItemType.values(), 0, 100);
            for (Map.Entry<RelatedItemType, List<AssociatedRecord>> entry : associated.entrySet()) {
                for (AssociatedRecord record : entry.getValue()) {
                    Element relation = new Element(entry.getKey().name());
                    relation.setAttribute("uuid", record.getUuid());
                    relation.setAttribute("origin", record.getOrigin());
                    if (record.getProperties() != null) {
                        if (record.getProperties().get("associationType") != null) {
                            relation.setAttribute("associationType", record.getProperties().get("associationType"));
                        }
                        if (record.getProperties().get("initiativeType") != null) {
                            relation.setAttribute("initiativeType", record.getProperties().get("initiativeType"));
                        }
                        if (record.getProperties().get("resourceTitle") != null) {
                            relation.setAttribute("resourceTitle", record.getProperties().get("resourceTitle"));
                        }
                        if (record.getProperties().get("url") != null) {
                            relation.setAttribute("url", record.getProperties().get("url"));
                        }
                    }
                    relation.addContent(Xml.getXmlFromJSON(record.getRecord().toPrettyString()));
                    relations.addContent(relation);
                }
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }

        DOMOutputter outputter = new DOMOutputter();
        try {
            return outputter.output(new Document(relations));
        } catch (JDOMException e) {
            throw new RuntimeException(e);
        }
    }


    public static Map<RelatedItemType, List<AssociatedRecord>> getAssociated(
        ServiceContext context,
        AbstractMetadata md, RelatedItemType[] types, int start, int size)
        throws Exception  {

        GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
        DataManager dm = gc.getBean(DataManager.class);
        SettingManager settingManager = gc.getBean(SettingManager.class);
        EsSearchManager searchMan = gc.getBean(EsSearchManager.class);

        Element xml = dm.getMetadata(context, md.getId() + "",
            FOR_EDITING, WITH_VALIDATION_ERRORS, KEEP_XLINK_ATTRIBUTES);

        SchemaPlugin instance = SchemaManager.getSchemaPlugin(md.getDataInfo().getSchemaId());
        final AssociatedResourcesSchemaPlugin schemaPlugin =
                instance instanceof AssociatedResourcesSchemaPlugin
                ? (AssociatedResourcesSchemaPlugin) instance : null;

        // For each type, store a query and expected list of uuids.
        Map<RelatedItemType, RelatedTypeDetails> queries = new HashMap<>();
        Set<String> allSearchedUuids = new HashSet<>();


        // We have 3 types of links
        // * Those who are in the XML eg.
        // parent (either parent identifier or associated resources),
        // services using operatesOn
        // sources
        // feature catalogues
        //
        // * Those who requires a search to find associated records eg.
        // children
        // brothers&sisters
        //
        // * All of them could be remote records
        Arrays.stream(types).forEach(type -> {
            if (type == RelatedItemType.associated
                || type == RelatedItemType.hasfeaturecats
                || type == RelatedItemType.services
                || type == RelatedItemType.hassources) {
                queries.put(type,
                    new RelatedTypeDetails(
                        String.format("+%s:\"%s\"",
                            RELATED_INDEX_FIELDS.get(type.value()), md.getUuid())
                    ));
            } else if (schemaPlugin != null
                && (type == RelatedItemType.siblings
                || type == RelatedItemType.parent
                || type == RelatedItemType.fcats
                || type == RelatedItemType.datasets
                || type == RelatedItemType.sources)) {
                Set<AssociatedResource> listOfAssociatedResources = new HashSet<>();
                if (type == RelatedItemType.siblings) {
                    listOfAssociatedResources = schemaPlugin.getAssociatedResourcesUUIDs(xml);
                } else if (type == RelatedItemType.sources) {
                    listOfAssociatedResources = schemaPlugin.getAssociatedSources(xml);
                } else if (type == RelatedItemType.datasets) {
                    listOfAssociatedResources = schemaPlugin.getAssociatedDatasets(xml);
                } else if (type == RelatedItemType.parent) {
                    listOfAssociatedResources = schemaPlugin.getAssociatedParents(xml);
                } else if (type == RelatedItemType.fcats) {
                    listOfAssociatedResources = schemaPlugin.getAssociatedFeatureCatalogues(xml);
                }


                Set<String> remoteRecords = new HashSet<>();
                if (type == RelatedItemType.parent || !listOfAssociatedResources.isEmpty()) {
                    Set<String> listOfUUIDs = listOfAssociatedResources.stream()
                        .map(AssociatedResource::getUuid)
                        .collect(Collectors.toSet());
                    Map<String, Map<String, String>> recordsProperties = new HashMap<>();
                    for(AssociatedResource r : listOfAssociatedResources) {
                        Map<String, String> properties = new HashMap<>();
                        properties.put("associationType", r.getAssociationType());
                        properties.put("initiativeType", r.getInitiativeType());
                        properties.put("resourceTitle", r.getTitle());
                        properties.put("url", r.getUrl());
                        recordsProperties.put(r.getUuid(), properties);
                        boolean isRemote = StringUtils.isNotEmpty(r.getUrl())
                            && !r.getUrl().startsWith(settingManager.getBaseURL());
                        if (isRemote) {
                            remoteRecords.add(r.getUuid());
                        }
                    }
                    queries.put(type,
                        new RelatedTypeDetails(
                            String.format("(uuid:(%s)%s) AND (draft:\"n\" OR draft:\"e\")",
                            listOfUUIDs.stream()
                                .collect(Collectors.joining("\" OR \"", "\"", "\"")),
                                type == RelatedItemType.parent
                                    ? " OR childUuid:" + "\"" + md.getUuid() + "\""
                                    : ""),
                            listOfUUIDs,
                            recordsProperties,
                            remoteRecords
                        ));
                    allSearchedUuids.addAll(listOfUUIDs);
                }
            } else if (schemaPlugin != null && type == RelatedItemType.brothersAndSisters) {
                // Get parents
                Set<String> listOfUUIDs = schemaPlugin.getAssociatedParentUUIDs(xml);
                // and search for records associated to them
                queries.put(type,
                    new RelatedTypeDetails(
                        String.format("+%s:(%s) -uuid:\"%s\" AND (draft:\"n\" OR draft:\"e\")",
                        RELATED_INDEX_FIELDS.get(type.value()),
                        listOfUUIDs.stream()
                            .collect(Collectors.joining("\" OR \"", "\"", "\"")),
                        md.getUuid()),
                        listOfUUIDs
                    ));
                allSearchedUuids.addAll(listOfUUIDs);
            } else if (schemaPlugin != null && type == RelatedItemType.children) {
                // Get associated with isComposedOf
                Set<AssociatedResource> listOfAssociated = schemaPlugin.getAssociatedResourcesUUIDs(xml);
                Set<String> isComposedOfList = listOfAssociated.stream()
                    .filter(e -> "isComposedOf".equals(e.getAssociationType()))
                    .map(AssociatedResource::getUuid)
                    .collect(Collectors.toSet());

                // and search for records associated and records having parentUuid equal to current
                queries.put(type,
                    new RelatedTypeDetails(
                        String.format("(%s:\"%s\" OR uuid:(%s)) AND (draft:\"n\" OR draft:\"e\")",
                            RELATED_INDEX_FIELDS.get(type.value()),
                            md.getUuid(),
                            isComposedOfList.stream()
                                .collect(Collectors.joining("\" OR \"", "\"", "\""))
                            ),
                        isComposedOfList
                    ));
                allSearchedUuids.addAll(isComposedOfList);
            }
        });


        Map<RelatedItemType, List<AssociatedRecord>> associated =
            new HashMap<>();
        Set<String> allCatalogueUuids = new HashSet<>();

        String privilegesFilter = buildPermissionsFilter(context);
        ObjectMapper mapper = new ObjectMapper();

        for (Map.Entry<RelatedItemType,RelatedTypeDetails> entry : queries.entrySet()) {
            // TODO: Use msearch ?
            RelatedTypeDetails relatedTypeDetails = entry.getValue();
            final SearchResponse result = searchMan.query(
                relatedTypeDetails.getQuery(),
                privilegesFilter,
                FIELDLIST_RELATED,
                FIELDLIST_RELATED_SCRIPTED,
                start, size);
            Set<String> expectedUuids = relatedTypeDetails.getExpectedRecords();
            Set<String> remoteRecords = relatedTypeDetails.getRemoteRecords();

            List<AssociatedRecord> records = new ArrayList<>();
            if (!result.hits().hits().isEmpty()) {
                for (Hit e : (List<Hit>) result.hits().hits()) {
                    allCatalogueUuids.add(e.id());
                    AssociatedRecord associatedRecord = new AssociatedRecord();
                    associatedRecord.setUuid(e.id());
                    // Set properties eg. remote, associationType, ...
                    associatedRecord.setProperties(relatedTypeDetails.recordsProperties.get(e.id()));

                    // Add scripted field values to the properties of the record
                    if (!e.fields().isEmpty()) {
                        FIELDLIST_RELATED_SCRIPTED.keySet().forEach(f -> {
                            JsonData dc = (JsonData) e.fields().get(f);

                            if (dc != null) {
                                if (associatedRecord.getProperties() == null) {
                                    associatedRecord.setProperties(new HashMap<>());
                                }
                                associatedRecord.getProperties().put(f, dc.toJson().asJsonArray().get(0).toString().replaceAll("^\"|\"$", ""));
                            }
                        });
                    }

                    JsonNode source = mapper.convertValue(e.source(), JsonNode.class);
                    ObjectNode doc = mapper.createObjectNode();
                    doc.set("_source", source);
                    EsHTTPProxy.addUserInfo(doc, context);
                    Iterator<String> fieldNames = doc.fieldNames();
                    while (fieldNames.hasNext()) {
                        String field = fieldNames.next();
                        if (!"_source".equals(field)) {
                            ((ObjectNode) source).set(field, doc.get(field));
                        }
                    }
                    associatedRecord.setRecord(source);
                    associatedRecord.setOrigin(RelatedItemOrigin.catalog.name());
                    records.add(associatedRecord);
                    if (expectedUuids.contains(e.id())) {
                        expectedUuids.remove(e.id());
                    }
                    // Remote records may be found in current catalogue (eg. if harvested)
                    if (remoteRecords.contains(e.id())) {
                        remoteRecords.remove(e.id());
                    }
                }
            }

            buildRemoteRecords(mapper, relatedTypeDetails, records);
            associated.put(entry.getKey(), records);
        }

        assignPortalOrigin(start, size, searchMan, associated, allCatalogueUuids);

        // TODO: Editable relation
        return associated;
    }

    private static void buildRemoteRecords(ObjectMapper mapper,
                                           RelatedTypeDetails relatedTypeDetails,
                                           List<AssociatedRecord> records) throws JsonProcessingException {
        for(String uuid : relatedTypeDetails.getRemoteRecords()) {
            AssociatedRecord associatedRecord = new AssociatedRecord();
            associatedRecord.setUuid(uuid);
            // Set properties eg. remote, url, title, associationType, ...
            associatedRecord.setProperties(relatedTypeDetails.recordsProperties.get(uuid));
            associatedRecord.setRecord(mapper.readTree(buildRemoteRecord(relatedTypeDetails.recordsProperties.get(uuid))));
            associatedRecord.setOrigin(RelatedItemOrigin.remote.name());
            records.add(associatedRecord);
        }
    }

    private static void assignPortalOrigin(int start, int size, EsSearchManager searchMan, Map<RelatedItemType, List<AssociatedRecord>> associated, Set<String> allCatalogueUuids) throws Exception {
        String portalFilter;
        SourceRepository sourceRepository = ApplicationContextHolder.get().getBean(SourceRepository.class);
        NodeInfo node = ApplicationContextHolder.get().getBean(NodeInfo.class);
        if (node != null && !NodeInfo.DEFAULT_NODE.equals(node.getId())) {
            final Optional<Source> portal = sourceRepository.findById(node.getId());
            if (portal.isPresent() && StringUtils.isNotEmpty(portal.get().getFilter())) {
                portalFilter = portal.get().getFilter();

                final SearchResponse recordsInPortal = searchMan.query(
                    String.format("+uuid:(%s)",
                        allCatalogueUuids.stream()
                            .collect(Collectors.joining("\" OR \"", "\"", "\""))),
                    portalFilter,
                    FIELDLIST_UUID,
                    start, size);

                Set<String> allPortalUuids = new HashSet<>();
                if (!recordsInPortal.hits().hits().isEmpty()) {
                    for (Hit e : (List<Hit>) recordsInPortal.hits().hits()) {
                        allPortalUuids.add(e.id());
                    }
                }

                if (!allPortalUuids.isEmpty()) {
                    associated.forEach((t, records) -> records.stream()
                        .filter(r -> allPortalUuids.contains(r.getUuid()))
                        .forEach(r -> r.setOrigin(RelatedItemOrigin.portal.name())));
                }
            }
        }
    }

    private static String buildRemoteRecord(Map<String, String> props) {
        return props == null || props.get("resourceTitle") == null
            ? "{}"
            : String.format("{\"resourceTitleObject\": {\"default\": \"%s\"}}",
                StringEscapeUtils.escapeJson(props.get("resourceTitle")));
    }

    @Deprecated
    public static Element getRelated(ServiceContext context, int iId,
                                     RelatedItemType[] type,
                                     int fromRecord, int toRecord)
        throws Exception {
        final String id = String.valueOf(iId);

        GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
        DataManager dm = gc.getBean(DataManager.class);

        Element relatedRecords = new Element("relations");


        if(type == null || type.length == 0) {
            type = RelatedItemType.class.getEnumConstants();
        }
        List<RelatedItemType> listOfTypes = new ArrayList<>(Arrays.asList(type));
        Element md = dm.getMetadata(context, id, FOR_EDITING, WITH_VALIDATION_ERRORS, KEEP_XLINK_ATTRIBUTES);

        // Feature catalogue records referenced from the metadata. Used by the
        // featureCatalog endpoint to decode feature attributes. The referenced
        // UUIDs come from the record content and each record is fetched
        // enforcing the view privilege, so no restricted record is exposed.
        if (md != null && (listOfTypes.isEmpty() || listOfTypes.contains(RelatedItemType.fcats))) {
            SchemaPlugin instance = SchemaManager.getSchemaPlugin(dm.getMetadataSchema(id));
            if (instance instanceof AssociatedResourcesSchemaPlugin) {
                AssociatedResourcesSchemaPlugin schemaPlugin = (AssociatedResourcesSchemaPlugin) instance;
                Set<String> listOfUUIDs = schemaPlugin.getAssociatedFeatureCatalogueUUIDs(md);
                Element fcat = new Element("fcats");
                if (listOfUUIDs != null) {
                    for (String fcatUuid : listOfUUIDs) {
                        Element current = getRecord(fcatUuid, context, dm);
                        if (current != null) {
                            Element metadata = new Element("metadata")
                                .setAttribute("origin", RelatedItemOrigin.catalog.name());
                            metadata.addContent(current);
                            fcat.addContent(new Element("response").addContent(metadata));
                        } else {
                            LOGGER.error("Feature catalogue with UUID {} referenced in record {} was not found or is not visible.", fcatUuid, id);
                        }
                    }
                }
                relatedRecords.addContent(fcat);
            }
        }

        // XSL transformation is used on the metadata record to extract
        // distribution information or thumbnails
        if (md != null && (listOfTypes.isEmpty() ||
            listOfTypes.contains(RelatedItemType.onlines) ||
            listOfTypes.contains(RelatedItemType.thumbnails))) {
            relatedRecords.addContent(new Element("metadata").addContent((Content) md.clone()));
        }

        return relatedRecords;
    }

    /**
     * Read a record enforcing the view privilege for the current user.
     *
     * @return the record content, or {@code null} if it does not exist or the
     * user is not allowed to view it.
     */
    private static Element getRecord(String uuid, ServiceContext context, DataManager dm) {
        Element content = null;
        try {
            String id = dm.getMetadataId(uuid);
            Lib.resource.checkPrivilege(context, id, ReservedOperation.view);
            content = dm.getMetadata(context, id, FOR_EDITING, WITH_VALIDATION_ERRORS, KEEP_XLINK_ATTRIBUTES);
        } catch (Exception e) {
            if (Log.isDebugEnabled(Geonet.SEARCH_ENGINE))
                Log.debug(Geonet.SEARCH_ENGINE, "Metadata " + uuid + " record is not visible for user.");
        }
        return content;
    }

    /**
     * Run a Lucene query expression and return a list of UUIDs.
     *
     * @param query
     * @return List of UUIDs to export
     */
    public static Set<String> getUuidsToExport(String query) throws Exception {
        ApplicationContext applicationContext = ApplicationContextHolder.get();
        EsSearchManager searchMan = applicationContext.getBean(EsSearchManager.class);

        Set<String> uuids = new HashSet<>();
        Set<String> field = new HashSet<>(1);
        field.add(Geonet.IndexFieldNames.UUID);

        int from = 0;
        SettingInfo si = applicationContext.getBean(SettingInfo.class);
        int size = Integer.parseInt(si.getSelectionMaxRecords());

        final SearchResponse result = searchMan.query(query, null, from, size);
        if (!result.hits().hits().isEmpty()) {
            final List<Hit> elements = result.hits().hits();
            ObjectMapper objectMapper = new ObjectMapper();
            elements.forEach(e -> uuids.add((String) objectMapper.convertValue(e.source(), Map.class).get(Geonet.IndexFieldNames.UUID)));
        }
        Log.info(Geonet.MEF, "  Found " + uuids.size() + " record(s).");
        return uuids;
    }

    /**
     * Returns the metadata validation status from the database, calculating/storing the validation if not stored.
     *
     * @param metadata
     * @param context
     * @return
     */
    public static boolean retrieveMetadataValidationStatus(AbstractMetadata metadata, ServiceContext context) throws Exception {
        MetadataValidationRepository metadataValidationRepository = context.getBean(MetadataValidationRepository.class);
        IMetadataValidator validator = context.getBean(IMetadataValidator.class);
        DataManager dataManager = context.getBean(DataManager.class);

        boolean hasValidation =
            (metadataValidationRepository.count(MetadataValidationSpecs.hasMetadataId(metadata.getId())) > 0);

        if (!hasValidation) {
            validator.doValidate(metadata, context.getLanguage());
            dataManager.indexMetadata(metadata.getId() + "", true);
        }

        boolean isInvalid =
            (metadataValidationRepository.count(MetadataValidationSpecs.isInvalidAndRequiredForMetadata(metadata.getId())) > 0);

        return isInvalid;
    }

    /**
     * Check if other metadata records exist apart from the one with {code}metadataUuidToExclude{code} with the same
     * {code}metadataValue{code} for the field {code}metadataField{code}.
     *
     * @param metadataValue         Metadata value to check.
     * @param metadataField         Metadata field to check the value.
     * @param metadataUuidToExclude Metadata identifier to exclude from the search.
     * @return A list of metadata uuids that have the same value for the field provided.
     */
    public static boolean isMetadataFieldValueExistingInOtherRecords(String metadataValue, String metadataField, String metadataUuidToExclude) {
        ApplicationContext applicationContext = ApplicationContextHolder.get();
        EsSearchManager searchMan = applicationContext.getBean(EsSearchManager.class);

        String esFieldName = "resourceTitleObject.\\\\*.keyword";
        if (metadataField.equals("altTitle")) {
            esFieldName = "resourceAltTitleObject.\\\\*.keyword";
        } else if (metadataField.equals("identifier")) {
            esFieldName = "resourceIdentifier.code";
        }

        boolean duplicatedMetadataValue = false;
        String jsonQuery = " {" +
            "       \"query_string\": {" +
            "       \"query\": \"+" + esFieldName + ":\\\"%s\\\" -uuid:\\\"%s\\\"\"" +
            "       }" +
            "}";

        ObjectMapper objectMapper = new ObjectMapper();
        try {
            JsonNode esJsonQuery = objectMapper.readTree(String.format(jsonQuery, metadataValue, metadataUuidToExclude));

            final SearchResponse queryResult = searchMan.query(
                esJsonQuery,
                FIELDLIST_UUID,
                0, 5);

            duplicatedMetadataValue = !queryResult.hits().hits().isEmpty();
        } catch (Exception ex) {
            Log.error(API.LOG_MODULE_NAME, ex.getMessage(), ex);
        }
        return duplicatedMetadataValue;
    }

}
