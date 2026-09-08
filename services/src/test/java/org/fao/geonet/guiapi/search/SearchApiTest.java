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

package org.fao.geonet.guiapi.search;

import co.elastic.clients.elasticsearch._types.aggregations.Aggregation;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.fao.geonet.constants.Geonet;
import org.jdom.Element;
import org.jdom.Verifier;
import org.junit.Assert;
import org.junit.Test;
import org.springframework.http.MediaType;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class SearchApiTest {

    @Test
    public void resultFieldsNeverExposesPrivilegeOrFilteredFields() {
        for (String field : SearchApi.RESULT_FIELDS) {
            Assert.assertFalse("must not request a privilege field: " + field,
                field.startsWith(Geonet.IndexFieldNames.OP_PREFIX));
            Assert.assertNotEquals("must not request online resource links", "link", field);
        }
    }

    @Test
    public void searchCriteriaKeepsRealSearchParams() {
        Map<String, String> params = new LinkedHashMap<>();
        params.put("resourceType", "dataset");
        params.put("fast", "index");
        params.put("from", "11");
        params.put("hitsPerPage", "20");
        params.put("_content_type", "xml");
        Assert.assertEquals(Map.of("resourceType", "dataset"), SearchApi.searchCriteria(params));
    }

    @Test
    public void negotiateResponseFormatPrefersContentTypeParamOverAccept() {
        Assert.assertEquals(SearchApi.ResponseFormat.XML,
            SearchApi.negotiateResponseFormat("xml", MediaType.TEXT_HTML_VALUE));
        Assert.assertEquals(SearchApi.ResponseFormat.JSON,
            SearchApi.negotiateResponseFormat("json", MediaType.TEXT_HTML_VALUE));
        Assert.assertEquals(SearchApi.ResponseFormat.HTML,
            SearchApi.negotiateResponseFormat("html", MediaType.APPLICATION_XML_VALUE));
    }

    @Test
    public void negotiateResponseFormatFallsBackToAcceptHeader() {
        Assert.assertEquals(SearchApi.ResponseFormat.XML,
            SearchApi.negotiateResponseFormat(null, MediaType.APPLICATION_XML_VALUE));
        Assert.assertEquals(SearchApi.ResponseFormat.JSON,
            SearchApi.negotiateResponseFormat(null, MediaType.APPLICATION_JSON_VALUE));
        Assert.assertEquals(SearchApi.ResponseFormat.HTML,
            SearchApi.negotiateResponseFormat(null, MediaType.TEXT_HTML_VALUE));
    }

    @Test
    public void searchCriteriaDropsAnythingNotOnTheAllowlist() {
        Map<String, String> params = new LinkedHashMap<>();
        params.put("op0", "1");
        params.put("op23", "5");
        params.put("lang", "fre");
        params.put("x\") OR (*:*", "y");
        params.put("resourceType", "dataset");
        Assert.assertEquals(Map.of("resourceType", "dataset"), SearchApi.searchCriteria(params));
    }

    @Test
    public void searchCriteriaIgnoresNonSearchAndBlankParams() {
        Map<String, String> params = new LinkedHashMap<>();
        params.put("fast", "index");
        params.put("resultType", "details");
        params.put("topicCat", "");
        Assert.assertTrue(SearchApi.searchCriteria(params).isEmpty());
    }

    @Test
    public void searchCriteriaStripsCharactersXmlCannotCarry() {
        Map<String, String> params = new LinkedHashMap<>();
        params.put("any", "coastal\u0008basins");

        Map<String, String> criteria = SearchApi.searchCriteria(params);

        Assert.assertEquals(Map.of("any", "coastalbasins"), criteria);
    }

    /**
     * The invariant behind {@link #searchCriteriaStripsCharactersXmlCannotCarry()}: every value
     * that survives has to be safe for the {@code <params>} element built from it, or
     * {@code Element.setText} throws {@code IllegalDataException} and the request 500s.
     */
    @Test
    public void searchCriteriaValuesAreAlwaysUsableAsXmlText() {
        Map<String, String> params = new LinkedHashMap<>();
        params.put("any", "\u0000\u0008rain\u001ffall\ufffe");
        params.put("topicCat", "farming\u000b");
        params.put("cat", "maps\ud83d");

        Map<String, String> criteria = SearchApi.searchCriteria(params);

        Assert.assertEquals(3, criteria.size());
        criteria.forEach((name, value) -> {
            Assert.assertNull("illegal XML text for " + name, Verifier.checkCharacterData(value));
            new Element(name).setText(value);
        });
    }

    @Test
    public void searchCriteriaKeepsCharactersOutsideTheBasicMultilingualPlane() {
        String beyondBmp = new String(Character.toChars(0x1F600)) + new String(Character.toChars(0x2A6B2));
        Map<String, String> params = new LinkedHashMap<>();
        params.put("any", beyondBmp);

        Assert.assertEquals(Map.of("any", beyondBmp), SearchApi.searchCriteria(params));
    }

    @Test
    public void searchCriteriaDropsAValueThatWasNothingButIllegalCharacters() {
        Map<String, String> params = new LinkedHashMap<>();
        params.put("any", "\u0008\u0000");
        params.put("resourceType", "dataset");

        Assert.assertEquals(Map.of("resourceType", "dataset"), SearchApi.searchCriteria(params));
    }

    @Test
    public void everyFacetAggregationAsksForMoreThanElasticsearchsDefaultTenBuckets() {
        Map<String, Aggregation> aggregations = SearchApi.buildFacetAggregations();

        Assert.assertEquals(Set.of("topicCat", "resourceType"), aggregations.keySet());
        aggregations.forEach((name, aggregation) -> {
            Integer size = aggregation.terms().size();
            Assert.assertNotNull("no explicit terms size for " + name, size);
            // MD_ScopeCode alone has 20 entries, MD_TopicCategoryCode 19.
            Assert.assertTrue("terms size too small for " + name + ": " + size, size >= 20);
        });
    }

    @Test
    public void facetAggregationsTargetTheRealIndexFields() {
        Map<String, Aggregation> aggregations = SearchApi.buildFacetAggregations();

        Assert.assertEquals("cl_topic.key", aggregations.get("topicCat").terms().field());
        Assert.assertEquals("resourceType", aggregations.get("resourceType").terms().field());
    }

    /** The default of the es.index.max_result_window.limit build property. */
    private static final long DEFAULT_RESULT_WINDOW = 15_000;

    @Test
    public void clampDisplayFromDefaultsToOne() {
        Assert.assertEquals(1, SearchApi.clampDisplayFrom(null, DEFAULT_RESULT_WINDOW));
        Assert.assertEquals(1, SearchApi.clampDisplayFrom("not-a-number", DEFAULT_RESULT_WINDOW));
        Assert.assertEquals(1, SearchApi.clampDisplayFrom("0", DEFAULT_RESULT_WINDOW));
        Assert.assertEquals(1, SearchApi.clampDisplayFrom("-5", DEFAULT_RESULT_WINDOW));
    }

    @Test
    public void clampDisplayFromKeepsAnOrdinaryValue() {
        Assert.assertEquals(11, SearchApi.clampDisplayFrom("11", DEFAULT_RESULT_WINDOW));
    }

    @Test
    public void clampDisplayFromNeverLetsFromPlusHitsPerPageExceedMaxResultWindow() {
        long clamped = SearchApi.clampDisplayFrom("1000000", DEFAULT_RESULT_WINDOW);
        Assert.assertEquals(14_991, clamped);
    }

    /**
     * The point of reading the window from configuration: a deployment that overrides
     * es.index.max_result_window.limit gets a clamp that matches its own index.
     */
    @Test
    public void clampDisplayFromFollowsAConfiguredResultWindow() {
        Assert.assertEquals(991, SearchApi.clampDisplayFrom("1000000", 1_000));
        Assert.assertEquals(99_991, SearchApi.clampDisplayFrom("1000000", 100_000));
        Assert.assertEquals(491, SearchApi.clampDisplayFrom("500", 500));
    }

    @Test
    public void maxDisplayFromIsTheFirstResultOfTheLastReachablePage() {
        Assert.assertEquals(14_991, SearchApi.maxDisplayFrom(DEFAULT_RESULT_WINDOW));
        // A window smaller than one page still leaves the first page reachable.
        Assert.assertEquals(1, SearchApi.maxDisplayFrom(10));
        Assert.assertEquals(1, SearchApi.maxDisplayFrom(1));
        Assert.assertEquals(1, SearchApi.maxDisplayFrom(0));
    }

    /**
     * maxDisplayFrom is what the page is told to stop paging at, so it has to agree with the
     * clamp the endpoint actually applies - otherwise a "next" link points at a "from" that
     * clamps back onto the page the reader is already on.
     */
    @Test
    public void maxDisplayFromIsTheHighestFromTheClampWillHonour() {
        for (long window : new long[]{1, 10, 11, 500, 1_000, 15_000, 100_000}) {
            long maxFrom = SearchApi.maxDisplayFrom(window);
            Assert.assertEquals("window " + window,
                maxFrom, SearchApi.clampDisplayFrom(String.valueOf(maxFrom), window));
            Assert.assertEquals("window " + window + ", one page past the end",
                maxFrom, SearchApi.clampDisplayFrom(String.valueOf(maxFrom + 1), window));
        }
    }

    @Test
    public void buildMustClausesWithNoCriteriaMatchesEverything() {
        ArrayNode must = SearchApi.buildMustClauses(new LinkedHashMap<>(), new ObjectMapper());
        Assert.assertEquals(1, must.size());
        Assert.assertTrue(must.get(0).has("match_all"));
    }

    @Test
    public void buildMustClausesAndsSearchParamsAsMatchPhraseClauses() {
        Map<String, String> criteria = new LinkedHashMap<>();
        criteria.put("resourceType", "dataset");
        criteria.put(Geonet.IndexFieldNames.CAT, "maps");
        ArrayNode must = SearchApi.buildMustClauses(criteria, new ObjectMapper());
        Assert.assertEquals(2, must.size());
        Assert.assertEquals("dataset", must.get(0).path("match_phrase").path("resourceType").asText());
        Assert.assertEquals("maps", must.get(1).path("match_phrase").path("cat").asText());
    }

    @Test
    public void buildMustClausesRewritesTypeToTheRealResourceTypeField() {
        Map<String, String> criteria = new LinkedHashMap<>();
        criteria.put("type", "map");
        ArrayNode must = SearchApi.buildMustClauses(criteria, new ObjectMapper());
        Assert.assertEquals("map", must.get(0).path("match_phrase").path("resourceType").asText());
    }

    @Test
    public void buildMustClausesRewritesGroupPublishedToTheFieldWithoutUnderscore() {
        Map<String, String> criteria = new LinkedHashMap<>();
        criteria.put("_groupPublished", "sample");
        ArrayNode must = SearchApi.buildMustClauses(criteria, new ObjectMapper());
        Assert.assertEquals("sample", must.get(0).path("match_phrase").path("groupPublished").asText());
    }

    @Test
    public void buildMustClausesSearchesAnyAcrossAnyAndTitleFieldsRegardlessOfLanguage() {
        Map<String, String> criteria = new LinkedHashMap<>();
        criteria.put("any", "coastal basins");
        ArrayNode must = SearchApi.buildMustClauses(criteria, new ObjectMapper());
        JsonNode multiMatch = must.get(0).path("multi_match");
        Assert.assertEquals("coastal basins", multiMatch.path("query").asText());
        Assert.assertEquals("and", multiMatch.path("operator").asText());
        List<String> fields = new ArrayList<>();
        multiMatch.path("fields").forEach(f -> fields.add(f.asText()));
        Assert.assertEquals(List.of("any.*", "resourceTitleObject.*^2"), fields);
    }

    @Test
    public void buildMustClausesRewritesTopicCatToTheRealCodelistField() {
        Map<String, String> criteria = new LinkedHashMap<>();
        criteria.put("topicCat", "farming");
        ArrayNode must = SearchApi.buildMustClauses(criteria, new ObjectMapper());
        Assert.assertEquals("farming", must.get(0).path("match_phrase").path("cl_topic.key").asText());
    }

    @Test
    public void buildMustClausesRewritesSourceToTheRealCatalogueField() {
        Map<String, String> criteria = new LinkedHashMap<>();
        criteria.put(Geonet.IndexFieldNames.SOURCE, "abc-123");
        ArrayNode must = SearchApi.buildMustClauses(criteria, new ObjectMapper());
        Assert.assertEquals("abc-123", must.get(0).path("match_phrase").path("sourceCatalogue").asText());
    }

    @Test
    public void buildMustClausesNeedsNoValueEscaping() {
        Map<String, String> criteria = new LinkedHashMap<>();
        criteria.put("title", "a\"b\\c");
        ArrayNode must = SearchApi.buildMustClauses(criteria, new ObjectMapper());
        Assert.assertEquals("a\"b\\c", must.get(0).path("match_phrase").path("title").asText());
    }

    @Test
    public void toResultElementFlattensEsSourceFields() {
        ObjectNode source = new ObjectMapper().createObjectNode();
        source.put(Geonet.IndexFieldNames.UUID, "abc-123");
        source.putObject("resourceTitleObject").put("default", "A title");
        source.putObject("resourceAbstractObject").put("default", "An abstract");
        source.putArray("resourceType").add("dataset").add("series");
        source.putArray(Geonet.IndexFieldNames.CAT).add("_administration").add("environment");
        source.putArray("overview").addObject().put("url", "http://example.org/thumb.png");

        Element metadata = SearchApi.toResultElement(source);

        Assert.assertEquals("abc-123",
            metadata.getChild("info", Geonet.Namespaces.GEONET).getChildText("uuid"));
        Assert.assertEquals("A title", metadata.getChildText("title"));
        Assert.assertNull(metadata.getChild("defaultTitle"));
        Assert.assertEquals("An abstract", metadata.getChildText("abstract"));
        Assert.assertEquals("dataset", metadata.getChildText("type"));
        Assert.assertEquals(2, metadata.getChildren("category").size());
        Element image = metadata.getChild("image");
        Assert.assertEquals("A title", image.getAttributeValue("alt"));
        Assert.assertEquals("http://example.org/thumb.png", image.getAttributeValue("url"));
    }

    @Test
    public void toResultElementKeepsAPipeInTheTitleIntact() {
        ObjectNode source = new ObjectMapper().createObjectNode();
        source.put(Geonet.IndexFieldNames.UUID, "abc-123");
        source.putObject("resourceTitleObject").put("default", "Rainfall | Temperature dataset");
        source.putArray("overview").addObject().put("url", "http://example.org/thumb.png");

        Element image = SearchApi.toResultElement(source).getChild("image");

        Assert.assertEquals("Rainfall | Temperature dataset", image.getAttributeValue("alt"));
        Assert.assertEquals("http://example.org/thumb.png", image.getAttributeValue("url"));
    }

    @Test
    public void toResultElementSkipsMissingResourceTypeAndOverview() {
        ObjectNode source = new ObjectMapper().createObjectNode();
        source.put(Geonet.IndexFieldNames.UUID, "abc-123");

        Element metadata = SearchApi.toResultElement(source);

        Assert.assertNull(metadata.getChild("type"));
        Assert.assertNull(metadata.getChild("image"));
        Assert.assertTrue(metadata.getChildren("category").isEmpty());
        Assert.assertEquals("abc-123", metadata.getChildText("defaultTitle"));
    }
}
