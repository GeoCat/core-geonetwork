package nl.kadaster.pdok.bussiness.registryservices.bean;

import nl.kadaster.pdok.bussiness.registryservices.CodelistElement;
import org.fao.geonet.kernel.KeywordBean;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

/**
 * Wrapper class of KeywordBean.
 */
@XmlRootElement
public class Location implements CodelistElement {

    private KeywordBean keywordBean;

    public Location() {
    }

    public Location(KeywordBean keywordBean) {
        this.keywordBean = keywordBean;
    }

    @XmlElement
    public String getCoordEast() {
        return this.keywordBean.getCoordEast();
    }

    @XmlElement
    public String getCoordWest() {
        return this.keywordBean.getCoordWest();
    }

    @XmlElement
    public String getCoordSouth() {
        return this.keywordBean.getCoordSouth();
    }

    @XmlElement
    public String getCoordNorth() {
        return this.keywordBean.getCoordNorth();
    }

    @XmlElement
    public String getKey() { return this.keywordBean.getUriCode(); }

    @XmlElement
    public String getLabel() { return this.keywordBean.getDefaultValue();}
}
