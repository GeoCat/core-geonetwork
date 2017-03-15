package nl.kadaster.pdok.bussiness.registryservices.bean;

import nl.kadaster.pdok.bussiness.registryservices.CodelistElement;

import javax.xml.bind.annotation.XmlRootElement;

/**
 * Created by juanluisrp on 14/01/2016.
 */
@XmlRootElement
public class Denominator implements Comparable<Denominator>, CodelistElement{
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
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        Denominator that = (Denominator) o;

        return key.equals(that.key);

    }

    @Override
    public int hashCode() {
        return key.hashCode();
    }

    @Override
    public int compareTo(Denominator o) {
        return key.compareTo(o.getKey());
    }
}
