package nl.kadaster.pdok.bussiness.registryservices.bean;

import nl.kadaster.pdok.bussiness.registryservices.Codelist;

/**
 * Created by juanluisrp on 13/01/2016.
 */
public class TopicCategory implements Codelist {
    private String id;
    private String name;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
