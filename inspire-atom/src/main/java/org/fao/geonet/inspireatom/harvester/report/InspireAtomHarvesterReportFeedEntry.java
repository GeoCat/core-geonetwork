package org.fao.geonet.inspireatom.harvester.report;

import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlRootElement;

/**
 * Inspire remote atom harvester report - feed entry status.
 */
@XmlRootElement(name = "feeds")
public class InspireAtomHarvesterReportFeedEntry {
    @XmlAttribute
    private String uuid;
    @XmlAttribute
    private String feed;
    @XmlAttribute
    private String status;
    @XmlAttribute
    private String error;

    public static InspireAtomHarvesterReportFeedEntry build(String uuid, String feed) {
        InspireAtomHarvesterReportFeedEntry entry = new InspireAtomHarvesterReportFeedEntry();
        entry.uuid = uuid;
        entry.feed = feed;
        entry.status = "ok";

        return entry;
    }

    public static InspireAtomHarvesterReportFeedEntry buildError(String uuid, String error) {
        InspireAtomHarvesterReportFeedEntry entry = new InspireAtomHarvesterReportFeedEntry();
        entry.uuid = uuid;
        entry.error = error;
        entry.status = "error";

        return entry;
    }

    public String getUuid() {
        return uuid;
    }

    public void setUuid(String uuid) {
        this.uuid = uuid;
    }

    public String getFeed() {
        return feed;
    }

    public void setFeed(String feed) {
        this.feed = feed;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
