package nl.kadaster.pdok.bussiness.registryservices;

/**
 * A Registry item with a name and the URL endpoint where it can be queried.
 */
public class Registry {
    private String name;
    private String url;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }
}
