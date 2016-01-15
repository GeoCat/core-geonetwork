package nl.kadaster.pdok.bussiness.registryservices.bean;

/**
 * Created by juanluisrp on 13/01/2016.
 */
public class License implements Comparable<License> {
    private String key;
    private String translation;

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public String getTranslation() {
        return translation;
    }

    public void setTranslation(String translation) {
        this.translation = translation;
    }

    @Override
    public int compareTo(License otherLicense) {
        int result = this.translation.compareTo(otherLicense.getTranslation());
        return result;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        License license = (License) o;

        return translation.equals(license.translation);

    }

    @Override
    public int hashCode() {
        return translation.hashCode();
    }
}
