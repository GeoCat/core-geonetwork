//=============================================================================
//===	Copyright (C) 2001-2023 Food and Agriculture Organization of the
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

package org.fao.geonet.kernel.harvest.harvester.geonet40;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.base.Function;
import com.google.common.io.CharStreams;
import org.apache.commons.lang.StringUtils;
import org.apache.http.Header;
import org.apache.http.HttpHeaders;
import org.apache.http.HttpHost;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.AuthCache;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.client.protocol.HttpClientContext;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.auth.BasicScheme;
import org.apache.http.impl.client.BasicAuthCache;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.message.BasicHeader;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.search.aggregations.Aggregation;
import org.elasticsearch.search.aggregations.bucket.histogram.DateHistogramAggregationBuilder;
import org.elasticsearch.search.aggregations.bucket.terms.ParsedStringTerms;
import org.elasticsearch.search.aggregations.bucket.terms.StringTerms;
import org.elasticsearch.search.aggregations.metrics.ParsedTopHits;
import org.elasticsearch.search.aggregations.metrics.TopHitsAggregationBuilder;
import org.elasticsearch.xcontent.ContextParser;
import org.elasticsearch.xcontent.NamedXContentRegistry;
import org.elasticsearch.xcontent.ParseField;
import org.elasticsearch.xcontent.XContentParser;
import org.elasticsearch.xcontent.json.JsonXContent;
import org.fao.geonet.domain.Group;
import org.fao.geonet.domain.Source;
import org.fao.geonet.exceptions.BadParameterEx;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.lib.Lib;
import org.fao.geonet.utils.GeonetHttpRequestFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.client.ClientHttpResponse;
import org.springframework.stereotype.Component;

import javax.annotation.Nullable;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Component
public class GeoNetworkApiClient {
    @Autowired
    private GeonetHttpRequestFactory requestFactory;

    @Autowired
    private SettingManager settingManager;

    /**
     * Retrieves the list of sources from the GeoNetwork server and creates a Map using the source uuid as the key.
     *
     * @param serverUrl     GeoNetwork server URL.
     * @return              Map of sources using the source uuid as the key.
     * @throws URISyntaxException
     * @throws IOException
     */
    public Map<String, Source> retrieveSources(String serverUrl, String user, String password) throws URISyntaxException, IOException {
        String sourcesJson = retrieveUrl(addUrlSlash(serverUrl) + "api/sources", user, password);

        ObjectMapper objectMapper = new ObjectMapper();
        List<Source> sourceList
            = objectMapper.readValue(sourcesJson, new TypeReference<>(){});

        Map<String, Source> sourceMap = new HashMap<>();
        sourceList.forEach(s -> sourceMap.put(s.getUuid(), s));
        return sourceMap;
    }


    /**
     * Retrieves the list of groups from the GeoNetwork server.
     *
     * @param serverUrl     GeoNetwork server URL.
     * @return              List of groups.
     * @throws URISyntaxException
     * @throws IOException
     */
    public List<Group> retrieveGroups(String serverUrl, String user, String password) throws URISyntaxException, IOException {
        String groupsJson = retrieveUrl(addUrlSlash(serverUrl) + "api/groups", user, password);

        ObjectMapper objectMapper = new ObjectMapper();
        return objectMapper.readValue(groupsJson, new TypeReference<>(){});
    }

    /**
     * Queries the GeoNetwork server and returns the results.
     *
     * @param serverUrl     GeoNetwork server URL.
     * @param query         ElasticSearch query.
     * @return
     * @throws URISyntaxException
     * @throws IOException
     */
    public SearchResponse query(String serverUrl, String query, String user, String password) throws URISyntaxException, IOException {
        HttpPost httpMethod = new HttpPost(createUrl(addUrlSlash(serverUrl) + "api/search/records/_search"));
        final Header headerContentType = new BasicHeader(HttpHeaders.CONTENT_TYPE, ContentType.APPLICATION_JSON.getMimeType());
        final Header header = new BasicHeader(HttpHeaders.ACCEPT, ContentType.APPLICATION_JSON.getMimeType());
        httpMethod.addHeader(headerContentType);
        httpMethod.addHeader(header);
        final StringEntity entity = new StringEntity(query);
        httpMethod.setEntity(entity);

        try (ClientHttpResponse httpResponse = doExecute(httpMethod, user, password)) {
            String jsonResponse = CharStreams.toString(new InputStreamReader(httpResponse.getBody()));

            return getSearchResponseFromJson(jsonResponse);
        }
    }


    /**
     * Retrieves a metadata MEF file from the GeoNetwork server.
     *
     * @param serverUrl     GeoNetwork server URL.
     * @param uuid          Metadata UUID to retrieve.
     * @return
     * @throws URISyntaxException
     * @throws IOException
     */
    public Path retrieveMEF(String serverUrl, String uuid, String user, String password) throws URISyntaxException, IOException {
        if (!Lib.net.isUrlValid(serverUrl)) {
            throw new BadParameterEx("Invalid URL", serverUrl);
        }

        Path tempFile = Files.createTempFile("temp-", ".dat");

        String url = addUrlSlash(serverUrl) +
            "/api/records/" + uuid + "/formatters/zip?withRelated=false";

        HttpGet httpMethod = new HttpGet(createUrl(url));
        final Header header = new BasicHeader(HttpHeaders.ACCEPT, "application/x-gn-mef-2-zip");
        httpMethod.addHeader(header);

        try (ClientHttpResponse httpResponse = doExecute(httpMethod, user, password)){
            Files.copy(httpResponse.getBody(), tempFile, StandardCopyOption.REPLACE_EXISTING);
        }

        return tempFile;
    }


    private URI createUrl(String jsonUrl) throws URISyntaxException {
        return new URI(jsonUrl);
    }

    private String retrieveUrl(String serverUrl, String user, String password) throws URISyntaxException, IOException {
        if (!Lib.net.isUrlValid(serverUrl)) {
            throw new BadParameterEx("Invalid URL", serverUrl);
        }

        HttpGet httpMethod = new HttpGet(createUrl(serverUrl));
        final Header header = new BasicHeader(HttpHeaders.ACCEPT, ContentType.APPLICATION_JSON.toString());
        httpMethod.addHeader(header);

        try ( ClientHttpResponse httpResponse = doExecute(httpMethod, user, password)){
            return CharStreams.toString(new InputStreamReader(httpResponse.getBody()));
        }
    }

    private String addUrlSlash(String url) {
        return url + (!url.endsWith("/") ? "/" : "");
    }

    private List<NamedXContentRegistry.Entry> getDefaultNamedXContents() {
        Map<String, ContextParser<Object, ? extends Aggregation>> map = new HashMap<>();
        map.put(TopHitsAggregationBuilder.NAME, (p, c) -> ParsedTopHits.fromXContent(p, (String) c));
        map.put(StringTerms.NAME, (p, c) -> ParsedStringTerms.fromXContent(p, (String) c));
        map.put(DateHistogramAggregationBuilder.NAME,(p, c) -> ParsedStringTerms.fromXContent(p, (String) c));
        return map.entrySet().stream()
            .map(entry -> new NamedXContentRegistry.Entry(Aggregation.class, new ParseField(entry.getKey()), entry.getValue()))
            .collect(Collectors.toList());
    }

    SearchResponse getSearchResponseFromJson(String jsonResponse) throws IOException {
        NamedXContentRegistry registry = new NamedXContentRegistry(getDefaultNamedXContents());
        XContentParser parser = JsonXContent.jsonXContent.createParser(registry, null, jsonResponse);
        return SearchResponse.fromXContent(parser);
    }


    protected ClientHttpResponse doExecute(HttpUriRequest method, String username, String password) throws IOException {
        final String requestHost = method.getURI().getHost();
        HttpClientContext httpClientContext = HttpClientContext.create();

        final Function<HttpClientBuilder, Void> requestConfiguration = new Function<>() {
            @Nullable
            @Override
            public Void apply(HttpClientBuilder input) {
                if (StringUtils.isNotEmpty(username) && StringUtils.isNotEmpty(password)) {
                    HttpHost targetHost = new HttpHost(
                        method.getURI().getHost(),
                        method.getURI().getPort(),
                        method.getURI().getScheme());

                    final BasicCredentialsProvider credentialsProvider = new BasicCredentialsProvider();
                    credentialsProvider.setCredentials(
                        new AuthScope(targetHost.getHostName(), targetHost.getPort()),
                        new UsernamePasswordCredentials(username, password));

                    final RequestConfig.Builder builder = RequestConfig.custom();
                    builder.setAuthenticationEnabled(true);
                    builder.setRedirectsEnabled(true);
                    builder.setRelativeRedirectsAllowed(true);
                    builder.setCircularRedirectsAllowed(true);
                    builder.setMaxRedirects(3);

                    input.setDefaultRequestConfig(builder.build());

                    // Preemptive authentication
                    // Create AuthCache instance
                    AuthCache authCache = new BasicAuthCache();
                    // Generate BASIC scheme object and add it to the local auth cache
                    BasicScheme basicAuth = new BasicScheme();
                    authCache.put(targetHost, basicAuth);

                    // Add AuthCache to the execution context
                    httpClientContext.setCredentialsProvider(credentialsProvider);
                    httpClientContext.setAuthCache(authCache);
                }

                Lib.net.setupProxy(settingManager, input, requestHost);
                input.useSystemProperties();

                return null;
            }
        };

        return requestFactory.execute(method, requestConfiguration, httpClientContext);
    }
}
