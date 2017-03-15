package nl.kadaster.pdok.bussiness.registryservices.bean;

import nl.kadaster.pdok.bussiness.registryservices.CodelistElement;

import javax.xml.bind.annotation.XmlRootElement;

/**
 * Created by juanluisrp on 13/01/2016.
 */
@XmlRootElement
public class License implements Comparable<License>, CodelistElement {
    private String key;
    private String label;

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    @Override
    public int compareTo(License otherLicense) {
        int result = this.label.compareTo(otherLicense.getLabel());
        return result;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        License license = (License) o;

        return label.equals(license.label);

    }

    @Override
    public int hashCode() {
        return label.hashCode();
    }
}
