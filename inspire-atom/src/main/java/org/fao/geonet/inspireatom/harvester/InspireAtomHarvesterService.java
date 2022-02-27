//=============================================================================
//===	Copyright (C) 2001-2022 Food and Agriculture Organization of the
//===	United Nations (FAO-UN), United Nations World Food Programme (WFP)
//===	and United Nations Environment Programme (UNEP)
//===
//===	This program is free software; you can redistribute it and/or modify
//===	it under the terms of the GNU General Public License as published by
//===	the Free Software Foundation; either version 2 of the License, or (at
//===	your option) any later version.
//===
//===	This program is distributed in the hope that it will be useful, but
//===	WITHOUT ANY WARRANTY; without even the implied warranty of
//===	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//===	General Public License for more details.
//===
//===	You should have received a copy of the GNU General Public License
//===	along with this program; if not, write to the Free Software
//===	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
//===
//===	Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===	Rome - Italy. email: geonetwork@osgeo.org
//==============================================================================
package org.fao.geonet.inspireatom.harvester;

import jeeves.server.context.ServiceContext;
import org.apache.commons.lang.StringUtils;
import org.elasticsearch.action.search.SearchResponse;
import org.fao.geonet.Logger;
import org.fao.geonet.api.es.EsHTTPProxy;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.AbstractMetadata;
import org.fao.geonet.domain.InspireAtomFeed;
import org.fao.geonet.domain.Metadata;
import org.fao.geonet.domain.MetadataType;
import org.fao.geonet.inspireatom.harvester.report.InspireAtomHarvesterReport;
import org.fao.geonet.inspireatom.harvester.report.InspireAtomHarvesterReportFeedEntry;
import org.fao.geonet.inspireatom.model.DatasetFeedInfo;
import org.fao.geonet.inspireatom.util.InspireAtomUtil;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.datamanager.IMetadataUtils;
import org.fao.geonet.kernel.search.EsSearchManager;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.kernel.setting.Settings;
import org.fao.geonet.lib.Lib;
import org.fao.geonet.repository.InspireAtomFeedRepository;
import org.fao.geonet.repository.specification.InspireAtomFeedSpecs;
import org.fao.geonet.repository.specification.MetadataSpecs;
import org.fao.geonet.utils.GeonetHttpRequestFactory;
import org.fao.geonet.utils.Log;
import org.fao.geonet.utils.Xml;
import org.fao.geonet.utils.XmlRequest;
import org.jdom.Element;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.net.URL;
import java.util.*;

import static org.fao.geonet.kernel.search.EsSearchManager.FIELDLIST_UUID;

@Service
public class InspireAtomHarvesterService {
    private final Logger logger = Log.createLogger(Geonet.ATOM);

    @Autowired
    InspireAtomFeedRepository inspireAtomFeedRepository;

    @Autowired
    DataManager dataMan;

    @Autowired
    IMetadataUtils metadataUtils;

    @Autowired
    SettingManager sm;

    @Autowired
    GeonetHttpRequestFactory geonetHttpRequestFactory;

    @Autowired
    EsSearchManager searchManager;

    @Autowired
    EsHTTPProxy esHTTPProxy;

    /**
     * Harvest an individual metadata. Used in OpenSearchDescription service to retrieve the atom
     * information for a metadata. Useful if metadata has been created in the catalog since the last
     * periodical harvesting.
     *
     * @param metadataId Metadata identifier
     */
    public final void harvestServiceMetadata(final ServiceContext context, final String metadataId) {

        AbstractMetadata iso19139Metadata = metadataUtils.findOne(
            Specification.where((Specification<Metadata>) MetadataSpecs.isType(MetadataType.METADATA))
                .and((Specification<Metadata>) MetadataSpecs.isIso19139Schema())
                .and((Specification<Metadata>) MetadataSpecs.hasMetadataId(Integer.parseInt(metadataId))));

        InspireAtomHarvesterReport report = new InspireAtomHarvesterReport();

        try {
            logger.info("ATOM feed harvest started for metadata: " + metadataId);

            // Value used in metadata editor for online resources to identify an INSPIRE atom resource
            String atomProtocol = sm.getValue(Settings.SYSTEM_INSPIRE_ATOM_PROTOCOL);

            // Removes all atom information from existing metadata. Harvester will reload with updated information
            logger.info("ATOM feed harvest: remove existing metadata feed");
            inspireAtomFeedRepository.deleteAll(InspireAtomFeedSpecs.hasMetadataId(Integer.parseInt(metadataId)));
            dataMan.indexMetadata(Arrays.asList(new String[]{metadataId}));

            // Process service metadata feeds
            //    datasetsInformation stores the dataset information for identifier and namespace for the services feed.
            //    This information is not available in the datasets feeds
            logger.info("ATOM feed harvest: processing service metadata feeds");

            // Retrieve the service metadata referencing atom feed document
            Map<String, String> serviceMetadataWithAtomFeed =
                InspireAtomUtil.retrieveServiceMetadataWithAtomFeed(dataMan, iso19139Metadata, atomProtocol);

            List<DatasetFeedInfo> datasetsInformation =
                processServiceMetadataFeeds(dataMan, serviceMetadataWithAtomFeed, report);

            // Process dataset metadata feeds related to the service metadata
            logger.info("ATOM feed harvest for metadata: " + metadataId + ",  processing dataset metadata feeds");
            processDatasetsMetadataFeeds(context, dataMan, datasetsInformation, report);

            logger.info("ATOM feed harvest finished for metadata: " + metadataId);
        } catch (Exception x) {
            logger.error("ATOM feed harvest error: " + x.getMessage());
            logger.error(x);
        }
    }


    /**
     * Process service metadata feeds.
     *
     * @return a Map with the datasets referenced in the service feeds (dataset-id,
     * dataset-namespace). The namespace is only available in the service feeds. Dataset feeds seem
     * not containing this information.
     */
    public List<DatasetFeedInfo> processServiceMetadataFeeds(final DataManager dataMan,
                                                              final Map<String, String> serviceMetadataWithAtomFeeds,
                                                             InspireAtomHarvesterReport report)
        throws Exception {

        List<DatasetFeedInfo> datasetsInformation = new ArrayList<>();

        long total = serviceMetadataWithAtomFeeds.entrySet().size();
        long i = 1;

        // Process the metadata retrieving the atom feed content and store it in the catalog.
        for (Map.Entry<String, String> entry : serviceMetadataWithAtomFeeds.entrySet()) {
            String metadataId = entry.getKey();
            String metadataUuid = dataMan.getMetadataUuid(metadataId);

            try {
                logger.info("Processing feed (" + i++ + "/"+ total + ") for service metadata with uuid:" + metadataUuid);

                String atomUrl = entry.getValue();
                logger.debug("Atom feed Url for service metadata (" + metadataUuid + "): " + atomUrl);

                String atomFeedDocument = retrieveRemoteAtomFeedDocument(atomUrl);
                logger.debug("Atom feed Document for service metadata (" + metadataUuid + "): " + atomFeedDocument);

                Element atomDoc = Xml.loadString(atomFeedDocument, false);

                if (!atomDoc.getNamespace().equals(Geonet.Namespaces.ATOM)) {
                    logger.warning("Atom feed Document (" + atomUrl + ") for service metadata (" + metadataUuid + ") is not a valid feed");
                    continue;
                }

                InspireAtomFeed inspireAtomFeed = InspireAtomFeed.build(atomDoc);
                inspireAtomFeed.setMetadataId(Integer.parseInt(metadataId));
                inspireAtomFeed.setAtomUrl(atomUrl);
                inspireAtomFeed.setAtom(atomFeedDocument);
                inspireAtomFeed.setAtomDatasetid("");
                inspireAtomFeed.setAtomDatasetns("");

                inspireAtomFeedRepository.save(inspireAtomFeed);

                // Index the metadata to store the atom feed information in the index
                dataMan.indexMetadata(Arrays.asList(new String[]{metadataId}));


                // Extract datasets information (identifier, namespace) from the service feed:
                //      The namespace is only available in service feed and no in dataset feeds.
                //      Also NGR metadata uses MD_Identifier instead of RS_Identifier so lacks of this information
                logger.debug("Extract datasets information (identifier, namespace) from service atom feed  (" + atomUrl + ")");

                datasetsInformation.addAll(InspireAtomUtil.extractRelatedDatasetsInfoFromServiceFeed(atomFeedDocument, dataMan));

                report.getFeeds().add(InspireAtomHarvesterReportFeedEntry.build(metadataUuid, atomUrl));
            } catch (Exception ex) {
                // Log exception and continue processing the other metadata
                logger.error("Failed to process atom feed for service metadata: " + metadataUuid + " " + ex.getMessage());
                logger.error(ex);
                report.getFeeds().add(InspireAtomHarvesterReportFeedEntry.buildError(metadataUuid, ex.getMessage()));
            }
        }

        return datasetsInformation;
    }

    /**
     * Process dataset metadata feeds.
     */
    public void processDatasetsMetadataFeeds(final DataManager dataMan,
                                             final List<DatasetFeedInfo> datasetsFeedInformation,
                                             final InspireAtomHarvesterReport report)
        throws Exception {

        processDatasetsMetadataFeeds(ServiceContext.get(), dataMan, datasetsFeedInformation, report);
    }

    /**
     * Process the feeds for a set datasets related to a service metadata.
     *
     * @param datasetsFeedInformation Datasets map (datasetid, namespace)
     */
    public void processDatasetsMetadataFeeds(final ServiceContext context,
                                              final DataManager dataMan,
                                              final List<DatasetFeedInfo> datasetsFeedInformation,
                                             final InspireAtomHarvesterReport report)
        throws Exception {

        long total = datasetsFeedInformation.size();
        long i = 1;

        // Process the metadata retrieving the atom feed content and store it in the catalog.
        for(DatasetFeedInfo datasetFeedInfo: datasetsFeedInformation) {
            String metadataUuid = "";

            try {
                // Find the metadata UUID using the resource identifier gmd:MD_Identifier/gmd:code
                // TODO
                metadataUuid = retrieveDatasetUuidFromIdentifier(datasetFeedInfo.identifier, context);

                String atomUrl = datasetFeedInfo.feedUrl;

                logger.info("Processing feed (" + i++ + "/"+ total + ") for dataset metadata with uuid:" + metadataUuid + ", feed url: " + atomUrl);

                if (StringUtils.isEmpty(metadataUuid)) {
                    logger.warning("Metadata with dataset identifier (" + datasetFeedInfo.identifier + ") is not available. Skip dataset feed processing");
                    continue;
                }

                if (!atomUrl.toLowerCase().endsWith(".xml")) {
                    logger.warning("Atom feed Document (" + atomUrl + ") for dataset metadata (" + metadataUuid + ") is not a valid feed");
                    continue;
                }

                String metadataId = dataMan.getMetadataId(metadataUuid);

                logger.debug("Dataset, id=" + datasetFeedInfo.identifier + ", namespace=" + datasetFeedInfo.namespace);

                String atomFeedDocument = retrieveRemoteAtomFeedDocument(atomUrl);
                logger.debug("Dataset feed: " + atomFeedDocument);

                Element atomDoc = Xml.loadString(atomFeedDocument, false);

                // Skip document if not a feed
                if (!atomDoc.getNamespace().equals(Geonet.Namespaces.ATOM)) {
                    logger.warning("Atom feed Document (" + atomUrl + ") for dataset metadata (" + metadataUuid + ") is not a valid feed");
                    continue;
                }

                InspireAtomFeed inspireAtomFeed = InspireAtomFeed.build(atomDoc);
                inspireAtomFeed.setMetadataId(Integer.parseInt(metadataId));
                inspireAtomFeed.setAtomDatasetid(datasetFeedInfo.identifier);
                inspireAtomFeed.setAtomDatasetns(datasetFeedInfo.namespace);
                inspireAtomFeed.setAtomUrl(atomUrl);
                inspireAtomFeed.setAtom(atomFeedDocument);

                inspireAtomFeedRepository.save(inspireAtomFeed);

                // Index the metadata to store the atom feed information in the index
                dataMan.indexMetadata(Arrays.asList(new String[]{metadataId}));

                report.getFeeds().add(InspireAtomHarvesterReportFeedEntry.build(metadataUuid, atomUrl));
            } catch (Exception ex) {
                // Log exception and continue processing the other metadata
                logger.error("Failed to process atom feed for dataset metadata: " + metadataUuid + " " + ex.getMessage());
                logger.error(ex);

                report.getFeeds().add(InspireAtomHarvesterReportFeedEntry.buildError(metadataUuid, ex.getMessage()));
            }
        }
    }


    private String retrieveRemoteAtomFeedDocument(final String url) throws Exception {
        XmlRequest remoteRequest = geonetHttpRequestFactory.createXmlRequest(new URL(url));

        Lib.net.setupProxy(sm, remoteRequest);

        Element atomFeed = remoteRequest.execute();

        return Xml.getString(atomFeed);
    }


    public String retrieveDatasetUuidFromIdentifier(String datasetIdCode, ServiceContext context) throws Exception {

        List<String> uuids = new ArrayList<>();

        final SearchResponse searchResponse = searchManager.query(
            String.format("resourceIdentifier.code:\"%s\"", datasetIdCode),
            esHTTPProxy.buildPermissionsFilter(context),
            FIELDLIST_UUID, 0, 1);

        Arrays.asList(searchResponse.getHits().getHits()).forEach(h ->
            uuids.add((String) h.getSourceAsMap().get(Geonet.IndexFieldNames.UUID)));

        if (uuids.isEmpty()) {
            return "";
        } else {
            return uuids.get(0);
        }
    }

    public List<String> searchMetadataByTypeAndProtocol(String type,
                                                        String protocol,
                                                        ServiceContext context)  throws Exception  {

        List<String> uuids = new ArrayList<>();

        final SearchResponse searchResponse = searchManager.query(
            String.format("resourceType:\"%s\" linkProtocol:\"%s\"", type, protocol),
            esHTTPProxy.buildPermissionsFilter(context),
            FIELDLIST_UUID, 0, 1);

        Arrays.asList(searchResponse.getHits().getHits()).forEach(h ->
            uuids.add((String) h.getSourceAsMap().get(Geonet.IndexFieldNames.UUID)));


        return uuids;
    }
}
