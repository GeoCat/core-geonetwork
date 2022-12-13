package org.fao.geonet;

import org.testcontainers.elasticsearch.ElasticsearchContainer;
import org.testcontainers.utility.DockerImageName;

public class GeoNetworkElasticsearchContainer extends ElasticsearchContainer {
    private static final String ELASTIC_SEARCH_DOCKER = "docker.elastic.co/elasticsearch/elasticsearch:7.15.1";

    private static final String CLUSTER_NAME = "cluster.name";

    private static final String ELASTIC_SEARCH = "elasticsearch";

    public GeoNetworkElasticsearchContainer() {
        super(DockerImageName.parse(ELASTIC_SEARCH_DOCKER));
        this.addFixedExposedPort(9200, 9200);
        this.addFixedExposedPort(9300, 9300);
        this.addEnv(CLUSTER_NAME, ELASTIC_SEARCH);
    }
}
