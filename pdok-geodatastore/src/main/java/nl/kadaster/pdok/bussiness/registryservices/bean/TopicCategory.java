package nl.kadaster.pdok.bussiness.registryservices.bean;

import nl.kadaster.pdok.bussiness.registryservices.CodelistElement;

import javax.xml.bind.annotation.XmlRootElement;

/**
 * Created by juanluisrp on 13/01/2016.
 */
@XmlRootElement
public class TopicCategory implements CodelistElement, Comparable<TopicCategory> {
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

        TopicCategory that = (TopicCategory) o;

        if (key != null ? !key.equals(that.key) : that.key != null) return false;
        return label != null ? label.equals(that.label) : that.label == null;

    }

    @Override
    public int hashCode() {
        int result = key != null ? key.hashCode() : 0;
        result = 31 * result + (label != null ? label.hashCode() : 0);
        return result;
    }

    @Override
    public int compareTo(TopicCategory o) {
        int result = this.label.compareTo(o.getLabel());
        return result;
    }
}
