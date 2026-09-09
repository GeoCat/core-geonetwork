/*
 * Copyright (C) 2001-2016 Food and Agriculture Organization of the
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

package org.fao.geonet.guiapi.search;

import co.elastic.clients.elasticsearch._types.SortOptions;
import co.elastic.clients.elasticsearch._types.SortOrder;
import co.elastic.clients.elasticsearch._types.aggregations.Aggregation;
import co.elastic.clients.elasticsearch._types.aggregations.StringTermsAggregate;
import co.elastic.clients.elasticsearch._types.aggregations.StringTermsBucket;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Hit;
import co.elastic.clients.elasticsearch.core.search.TotalHits;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jeeves.server.context.ServiceContext;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.math.NumberUtils;
import org.fao.geonet.ApplicationContextHolder;
import org.fao.geonet.NodeInfo;
import org.fao.geonet.api.ApiUtils;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.constants.Params;
import org.fao.geonet.kernel.search.EsFilterBuilder;
import org.fao.geonet.kernel.search.EsQueryFilterUtils;
import org.fao.geonet.kernel.search.EsSearchManager;
import org.fao.geonet.utils.Log;
import org.fao.geonet.utils.Xml;
import org.jdom.Element;
import org.jdom.Verifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationContext;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

@RequestMapping(value = {
    "/{portal}/search"
})
@Tag(name = "search",
    description = "Search operations")
@Controller("search")
public class SearchApi {
    // The only filters this page offers, whether via its own links (any, topicCat,
    // resourceType, cat) or a classic-search URL a user might arrive with (type, the old name
    // for resourceType; _groupPublished; _source). Anything else - a stale bookmark, lang=, a
    // copy-pasted URL, hitsPerPage, _content_type, op0 - is silently ignored rather than turned
    // into a match_phrase clause against a field that was never meant to be searched.
    private static final Set<String> ALLOWED_SEARCH_PARAMS = Set.of(
        Params.FILTER_ANY, Geonet.SearchResult.TOPIC_CAT, "resourceType",
        Params.FILTER_TYPE, Geonet.IndexFieldNames.CAT, Params.FILTER_GROUP, Params.FILTER_CATALOG);

    // Facets on the page (display name -> aggregation field). "topicCat" isn't itself indexed;
    // the real field is "cl_topic.key".
    private static final Map<String, String> FACET_FIELDS = new LinkedHashMap<>();

    static {
        FACET_FIELDS.put("topicCat", "cl_topic.key");
        FACET_FIELDS.put("resourceType", "resourceType");
    }

    // A terms aggregation returns 10 buckets unless told otherwise, which silently hides
    // facet values: MD_TopicCategoryCode has 19 entries and MD_ScopeCode 20 in ISO19139
    // alone, and other schema plugins add to resourceType. The JS app can cap its own facets
    // lower (CatController.js uses 20 and 10) because its panel has a "show more" control;
    // this page has none, so every value has to arrive in the one request. Both facets are
    // closed codelists in the low tens - this leaves headroom without paging them.
    private static final int FACET_SIZE = 50;

    // _source fields this endpoint reads - never "op*" (privilege) or schema-filtered fields
    // (e.g. "link"), matching EsHTTPProxy's own protections.
    static final Set<String> RESULT_FIELDS = Set.of(
        Geonet.IndexFieldNames.UUID, "resourceTitleObject", "resourceAbstractObject",
        "resourceType", "overview", Geonet.IndexFieldNames.CAT);

    private static final int HITS_PER_PAGE = 10;

    // ES's own paging limit for the records index (index.max_result_window): the highest
    // "from + size" it will accept. Injected from the same build property that fills the
    // setting in records.json, so a deployment that raises or lowers one moves both; the
    // default matches the property's own default in pom.xml. Paging is clamped to it to
    // avoid a hard error on a "from" far past the last page.
    @Value("${es.index.max_result_window.limit:15000}")
    private long maxResultWindow;

    // Deterministic tiebreak: a bare match_all query ties every hit on _score, and ES doesn't
    // guarantee stable order across pages without one.
    private static final List<SortOptions> SORT = List.of(
        SortOptions.of(s -> s.field(f -> f.field("_score").order(SortOrder.Desc))),
        SortOptions.of(s -> s.field(f -> f.field("uuid").order(SortOrder.Asc))));

    @Operation(
        summary = "Search without JavaScript",
        description = "Runs a search from the request's query parameters and renders the " +
            "no-JS degraded search page (or the same results as JSON/XML, via _content_type " +
            "or Accept).")
    @RequestMapping(
        produces = {
            MediaType.TEXT_HTML_VALUE,
            MediaType.APPLICATION_JSON_VALUE,
            MediaType.APPLICATION_XML_VALUE
        },
        method = RequestMethod.GET
    )
    @ResponseStatus(value = HttpStatus.OK)
    public void getFieldInfo(
        @Parameter(hidden = true)
            HttpServletRequest request,
        @Parameter(hidden = true)
            HttpServletResponse response,
        @Parameter(hidden = true)
        @RequestHeader(
            value = "Accept",
            defaultValue = MediaType.TEXT_HTML_VALUE
        )
            String accept,
        @Parameter(hidden = true)
        @RequestParam
            Map<String, String> allRequestParams
    ) throws Exception {
        ResponseFormat format = negotiateResponseFormat(allRequestParams.get(Params.CONTENT_TYPE), accept);
        boolean isXml = format == ResponseFormat.XML;
        boolean isJson = format == ResponseFormat.JSON;

        response.setHeader("Content-type",
            (isXml ? MediaType.APPLICATION_XML_VALUE : isJson ? MediaType.APPLICATION_JSON_VALUE : "text/html")
                + ";charset=utf-8");

        Element results = query(allRequestParams, request);
        if (isXml) {
            response.getWriter().write(Xml.getString(results));
        } else if (isJson) {
            response.getWriter().write(Xml.getJSON(results));
        } else {
            response.getWriter().write(
                new XsltResponseWriter(null, "search")
                    .withJson("catalog/locales/en-core.json")
                    .withJson("catalog/locales/en-search.json")
                    .withXml(results)
                    .withXsl("xslt/ui-search/search-nojs.xsl")
                    .asHtml()
            );
        }
    }

    enum ResponseFormat {HTML, JSON, XML}

    /**
     * _content_type (spring-servlet.xml's favorParameter) wins over Accept when present - same
     * content-negotiation convention as the rest of the app.
     */
    static ResponseFormat negotiateResponseFormat(String contentTypeParam, String accept) {
        if (contentTypeParam != null) {
            if ("xml".equalsIgnoreCase(contentTypeParam)) {
                return ResponseFormat.XML;
            }
            if ("json".equalsIgnoreCase(contentTypeParam)) {
                return ResponseFormat.JSON;
            }
            return ResponseFormat.HTML;
        }
        if (MediaType.APPLICATION_XML_VALUE.equals(accept)) {
            return ResponseFormat.XML;
        }
        if (MediaType.APPLICATION_JSON_VALUE.equals(accept)) {
            return ResponseFormat.JSON;
        }
        return ResponseFormat.HTML;
    }

    /**
     * Runs the search for the no-JS degraded search page.
     */
    private Element query(Map<String, String> queryFields, HttpServletRequest request) throws Exception {
        ApplicationContext applicationContext = ApplicationContextHolder.get();
        EsSearchManager searchMan = applicationContext.getBean(EsSearchManager.class);
        ServiceContext context = ApiUtils.createServiceContext(request);
        NodeInfo node = applicationContext.getBean(NodeInfo.class);

        Map<String, String> criteria = searchCriteria(queryFields);

        ObjectMapper objectMapper = new ObjectMapper();
        ObjectNode boolQuery = objectMapper.createObjectNode();
        boolQuery.set("must", buildMustClauses(criteria, objectMapper));
        ObjectNode queryNode = objectMapper.createObjectNode();
        queryNode.set("bool", boolQuery);

        // Structural bool.filter, always ANDed regardless of "must" - not EsSearchManager's
        // "filterQuery", which becomes a post_filter and wouldn't affect hits.total/paging.
        // Same assembly OAI-PMH (kernel.oaipmh.Lib.search) and EsHTTPProxy use.
        JsonNode permissionsFilter = EsQueryFilterUtils.buildQueryStringFilter(objectMapper,
            EsFilterBuilder.build(context, "metadata", false, node));
        ObjectNode wrappedSearchRequest = objectMapper.createObjectNode();
        wrappedSearchRequest.set("query", queryNode);
        EsQueryFilterUtils.addFilterToQuery(objectMapper, wrappedSearchRequest, permissionsFilter);
        JsonNode query = wrappedSearchRequest.get("query");

        long displayFrom = clampDisplayFrom(queryFields.get("from"), maxResultWindow);
        int esFrom = (int) (displayFrom - 1);

        // A query ES rejects for any reason throws here. Degrade to "no results" instead of a
        // raw error page, same pattern as addFacets.
        long count = 0;
        List<Hit> hits = List.of();
        try {
            SearchResponse result = searchMan.query(query, RESULT_FIELDS, esFrom, HITS_PER_PAGE, SORT);
            TotalHits total = result.hits().total();
            count = total != null ? total.value() : 0;
            hits = result.hits().hits();
        } catch (Exception e) {
            logDegradedSearch("running the search", e);
        }

        Element search = new Element("search");
        Element params = new Element("params");
        criteria.forEach((k, v) -> params.addContent(new Element(k).setText(v)));
        search.addContent(params);

        Element response = new Element("response");
        // Reflects whether this page has hits, not just whether the search matched anything.
        response.setAttribute("from", String.valueOf(hits.isEmpty() ? 0 : displayFrom));
        response.setAttribute("to", String.valueOf(hits.isEmpty() ? 0 : displayFrom - 1 + hits.size()));
        response.setAttribute("hitsPerPage", String.valueOf(HITS_PER_PAGE));
        // Where paging stops regardless of the hit count, so the page doesn't offer a "next"
        // that clamps straight back onto the page the reader is already looking at.
        response.setAttribute("maxFrom", String.valueOf(maxDisplayFrom(maxResultWindow)));

        Element summary = new Element("summary");
        summary.setAttribute("count", String.valueOf(count));
        if (count > 0) {
            addFacets(searchMan, query, summary);
        }
        response.addContent(summary);

        for (Hit hit : hits) {
            ObjectNode source = (ObjectNode) hit.source();
            if (source == null) {
                continue;
            }
            response.addContent(toResultElement(source));
        }
        search.addContent(response);
        return search;
    }

    /**
     * The 1-based display index of the first result on the page: at least 1, and clamped to
     * {@link #maxDisplayFrom(long)} so esFrom + HITS_PER_PAGE never exceeds the index's
     * result window.
     */
    static long clampDisplayFrom(String fromParam, long maxResultWindow) {
        return Math.min(Math.max(1, NumberUtils.toLong(fromParam, 1)), maxDisplayFrom(maxResultWindow));
    }

    /**
     * The highest "from" this endpoint will honour - the first result of the last page inside
     * the result window. Sent to the page as {@code @maxFrom} so it knows where paging stops:
     * past this point there are no more pages to link to even when the hit count is higher.
     */
    static long maxDisplayFrom(long maxResultWindow) {
        return Math.max(1, maxResultWindow - HITS_PER_PAGE + 1);
    }

    /**
     * Search criteria: an allowed filter name (see ALLOWED_SEARCH_PARAMS), not blank, with
     * anything XML can't carry stripped out. Both {@code <params>} and the query are built
     * from this, so filtering here keeps the two in step.
     */
    static Map<String, String> searchCriteria(Map<String, String> queryFields) {
        Map<String, String> criteria = new LinkedHashMap<>();
        queryFields.forEach((k, v) -> {
            if (!ALLOWED_SEARCH_PARAMS.contains(k) || StringUtils.isBlank(v)) {
                return;
            }
            String value = stripIllegalXmlCharacters(v);
            // A value that was nothing but illegal characters is dropped, like a blank one.
            if (StringUtils.isNotBlank(value)) {
                criteria.put(k, value);
            }
        });
        return criteria;
    }

    /**
     * Drops the code points XML 1.0 has no representation for - C0 controls other than tab,
     * CR and LF, unpaired surrogates, and the two non-characters at the end of the BMP.
     *
     * <p>A query string can carry any of them: {@code ?any=%08} decodes to a backspace, and
     * {@code <params>} is built from these values, where {@code Element.setText} rejects them
     * with an {@link org.jdom.IllegalDataException} - an unchecked exception that would escape
     * as a 500 on a request anyone can make. Iterates by code point, not by char, so
     * characters outside the BMP (emoji, and much of CJK Extension B onwards) survive intact
     * rather than being torn in half.
     */
    private static String stripIllegalXmlCharacters(String value) {
        if (value.codePoints().allMatch(Verifier::isXMLCharacter)) {
            return value;
        }
        StringBuilder stripped = new StringBuilder(value.length());
        value.codePoints()
            .filter(Verifier::isXMLCharacter)
            .forEach(stripped::appendCodePoint);
        return stripped.toString();
    }

    /**
     * Builds the query's "must" clauses from search criteria, or match_all when there are none.
     * "any" (free text) is a multi_match with operator "and" across "any.*" and
     * "resourceTitleObject.*" - every language sub-field of both (any.common, any.default,
     * any.langeng, any.langfre, ..., and the same for resourceTitleObject) in one query,
     * mirroring the wildcarded field patterns the JS app's own search (CatController.js) uses
     * in its query_string equivalent. This avoids having to know which language a visitor or a
     * record is in: the JS app doesn't trust the visitor's browser locale for this either - it
     * auto-detects the query text's own language - and picking one field by the request's
     * Accept-Language (an earlier version of this fix) broke as soon as a Spanish-locale
     * visitor searched English content, since none of any.langspa/resourceTitleObject.langspa
     * had a thing to match against. any.common alone (the original behaviour here) never
     * matches a title or abstract search: those copy_to any.&lt;lang&gt;/any.default, not
     * any.common, which only covers keyword-ish sources (links, resourceIdentifier, feature
     * type codes). Everything else (codelist/exact filters like topicCat) is a match_phrase
     * term: the value is one exact token, not free text. Values are JSON leaves either way,
     * not query-string syntax.
     *
     * <p>resourceTitleObject.* is boosted ^2, tracking the app's own preference for title
     * matches over abstract matches (it uses several boost factors depending on context; ^2 is
     * the one it uses for this same plain any-with-operator-and shape). The same wildcard also
     * expands to resourceTitleObject's keyword/sort/trigram/reverse sub-fields - harmless, not
     * a query-shape error, and the app's own resourceTitleObject.* expands identically; those
     * sub-fields just don't contribute (.reverse in particular would need a reversed query
     * token, which this endpoint doesn't build).
     */
    static ArrayNode buildMustClauses(Map<String, String> criteria, ObjectMapper mapper) {
        ArrayNode must = mapper.createArrayNode();
        criteria.forEach((k, v) -> {
            if (Params.FILTER_ANY.equals(k)) {
                must.add(buildAnyClause(v, mapper));
            } else {
                must.addObject().putObject("match_phrase").put(remapFieldName(k), v);
            }
        });
        if (must.isEmpty()) {
            must.addObject().putObject("match_all");
        }
        return must;
    }

    private static ObjectNode buildAnyClause(String value, ObjectMapper mapper) {
        ObjectNode multiMatch = mapper.createObjectNode();
        multiMatch.put("query", value);
        multiMatch.putArray("fields").add("any.*").add("resourceTitleObject.*^2");
        multiMatch.put("operator", "and");
        ObjectNode wrapper = mapper.createObjectNode();
        wrapper.set("multi_match", multiMatch);
        return wrapper;
    }

    /**
     * "topicCat" -> "cl_topic.key" (the real codelist field). "type" -> "resourceType" (the
     * classic-search name for the same facet). "_groupPublished" -> "groupPublished" (the
     * classic-search name has no leading underscore in the index). "_source" -> "sourceCatalogue"
     * (the indexer renames it; querying "_source" collides with ES's own reserved field).
     */
    private static String remapFieldName(String field) {
        if (Geonet.SearchResult.TOPIC_CAT.equals(field)) {
            return "cl_topic.key";
        }
        if (Params.FILTER_TYPE.equals(field)) {
            return "resourceType";
        }
        if (Params.FILTER_GROUP.equals(field)) {
            return Geonet.IndexFieldNames.GROUP_PUBLISHED;
        }
        if (Geonet.IndexFieldNames.SOURCE.equals(field)) {
            return "sourceCatalogue";
        }
        return field;
    }

    /**
     * Reports a step of the search that failed and was degraded away rather than propagated -
     * an empty result page, or a facet panel without that dimension.
     *
     * <p>Deliberately logs neither {@code e.getMessage()} nor the throwable. Every caller of
     * this endpoint is anonymous, both steps run the same user-supplied query, and both can
     * therefore be made to fail on demand - a "from" past the deployment's real result window,
     * or a value Elasticsearch won't parse. An Elasticsearch error message quotes the offending
     * request back, and criteria values can still legitimately contain CR and LF (XML allows
     * them, so {@link #searchCriteria} keeps them), so logging one verbatim - directly or via
     * the throwable's own stack trace - would let a crafted search forge log lines. The
     * exception class name is fixed text and still says what kind of failure it was.
     *
     * <p>Both steps share this one method so the two cannot drift apart: the same query, the
     * same exposure, the same reasoning about what is safe to write to the log.
     */
    private static void logDegradedSearch(String step, Exception e) {
        Log.warning(Geonet.GEONETWORK,
            "No-JS search degraded, " + step + " failed with " + e.getClass().getName());
    }

    /**
     * One terms aggregation per facet on the page, each with an explicit {@link #FACET_SIZE}
     * so no codelist value is dropped from the panel.
     */
    static Map<String, Aggregation> buildFacetAggregations() {
        Map<String, Aggregation> aggregations = new LinkedHashMap<>();
        FACET_FIELDS.forEach((name, field) ->
            aggregations.put(name, Aggregation.of(a -> a.terms(t -> t.field(field).size(FACET_SIZE)))));
        return aggregations;
    }

    /**
     * Adds a &lt;dimension&gt; per facet field with its value/count buckets. Logs and skips on
     * failure rather than breaking the search.
     */
    private void addFacets(EsSearchManager searchMan, JsonNode queryJson, Element summary) {
        try {
            SearchResponse<Void> aggResponse = searchMan.aggregate(queryJson, buildFacetAggregations());

            for (String field : FACET_FIELDS.keySet()) {
                StringTermsAggregate terms = aggResponse.aggregations().get(field).sterms();
                List<StringTermsBucket> buckets = terms.buckets().array();
                if (buckets.isEmpty()) {
                    continue;
                }
                Element dimension = new Element("dimension");
                dimension.setAttribute("name", field);
                dimension.setAttribute("label", field);
                for (StringTermsBucket bucket : buckets) {
                    Element category = new Element("category");
                    category.setAttribute("value", bucket.key().stringValue());
                    category.setAttribute("label", bucket.key().stringValue());
                    category.setAttribute("count", String.valueOf(bucket.docCount()));
                    dimension.addContent(category);
                }
                summary.addContent(dimension);
            }
        } catch (Exception e) {
            logDegradedSearch("computing the facets", e);
        }
    }

    /**
     * Flattens one ES hit into the &lt;metadata&gt; shape search-nojs.xsl reads.
     */
    static Element toResultElement(ObjectNode source) {
        Element metadata = new Element("metadata");

        String uuid = source.path(Geonet.IndexFieldNames.UUID).asText();
        Element info = new Element("info", Geonet.Namespaces.GEONET);
        info.addContent(new Element("uuid").setText(uuid));
        metadata.addContent(info);

        String title = source.path("resourceTitleObject").path("default").asText("");
        metadata.addContent(new Element("title").setText(title));
        if (title.isEmpty()) {
            // search-nojs.xsl falls back to this when title is blank, so the result still has a
            // usable, non-empty link label.
            metadata.addContent(new Element("defaultTitle").setText(uuid));
        }
        metadata.addContent(new Element("abstract")
            .setText(source.path("resourceAbstractObject").path("default").asText("")));

        JsonNode resourceType = source.path("resourceType");
        if (resourceType.isArray() && resourceType.size() > 0) {
            metadata.addContent(new Element("type").setText(resourceType.get(0).asText()));
        }

        for (JsonNode category : source.path(Geonet.IndexFieldNames.CAT)) {
            metadata.addContent(new Element("category").setText(category.asText()));
        }

        JsonNode overview = source.path("overview");
        if (overview.isArray() && overview.size() > 0) {
            // Separate attributes, not a delimited string, so a "|" in the title can't corrupt either.
            Element image = new Element("image");
            image.setAttribute("alt", title);
            image.setAttribute("url", overview.get(0).path("url").asText());
            metadata.addContent(image);
        }

        return metadata;
    }
}
