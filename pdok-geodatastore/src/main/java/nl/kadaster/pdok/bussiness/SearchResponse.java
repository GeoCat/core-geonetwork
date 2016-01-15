package nl.kadaster.pdok.bussiness;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.google.common.collect.Lists;
import jeeves.constants.Jeeves;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.math.NumberUtils;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.constants.Params;
import org.fao.geonet.kernel.KeywordBean;
import org.jdom.Element;

import javax.activation.MimetypesFileTypeMap;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by JuanLuis on 16/07/2015.
 */
public class SearchResponse {
    private Integer from;
    private Integer to;
    private Integer selected;
    private Integer count;

    @JsonIgnore
    private LocationManager locationManager;
    @JsonIgnore
    private String locationThesaurus;
    private List<MetadataParametersBean> metadata;

    public SearchResponse(LocationManager locationManager, String locationThesaurus) {
        this.locationManager = locationManager;
        this.locationThesaurus = locationThesaurus;
    }

    public SearchResponse() {
        metadata = new ArrayList<>();
    }

    private static List<String> getStringListOf(Element metadataEl, String childName) {
        List<Element> children = metadataEl.getChildren(childName);
        List<String> result = Lists.newArrayListWithCapacity(children.size());
        for (Element child : children) {
            result.add(child.getText());
        }
        return result;
    }

    public Integer getFrom() {
        return from;
    }

    public void setFrom(Integer from) {
        this.from = from;
    }

    public Integer getTo() {
        return to;
    }

    public void setTo(Integer to) {
        this.to = to;
    }

    public Integer getSelected() {
        return selected;
    }

    public void setSelected(Integer selected) {
        this.selected = selected;
    }

    public Integer getCount() {
        return count;
    }

    public void setCount(Integer count) {
        this.count = count;
    }

    public List<MetadataParametersBean> getMetadata() {
        return metadata;
    }

    public void setMetadata(List<MetadataParametersBean> metadata) {
        this.metadata = metadata;
    }

    public SearchResponse initFromXml(Element element) {
        if (element != null && element.getName().equals(Jeeves.Elem.RESPONSE)) {
            from = NumberUtils.toInt(element.getAttributeValue("from"));
            to = NumberUtils.toInt(element.getAttributeValue("to"));
            selected = NumberUtils.toInt(element.getAttributeValue(Params.SELECTED));
            Element summary = element.getChild(Geonet.Elem.SUMMARY);
            if (summary != null) {
                count = NumberUtils.toInt(summary.getAttributeValue("count"));
            }
            List<Element> metadataList = element.getChildren(Geonet.Elem.METADATA);
            metadata = Lists.newArrayListWithCapacity(metadataList.size());
            for (Element metadataEl : metadataList) {
                MetadataParametersBean md = getMetadataParametersBeanFromElement(metadataEl);

                metadata.add(md);
            }
        }
        return this;
    }

    public MetadataParametersBean getMetadataParametersBeanFromElement(Element metadataEl) {
        MetadataParametersBean md = new MetadataParametersBean();
        md.setTitle(metadataEl.getChildText("defaultTitle"));
        md.setSummary(metadataEl.getChildText("abstract"));
        md.setKeywords(getStringListOf(metadataEl, "keyword"));
        md.setTopicCategories(getStringListOf(metadataEl, Geonet.SearchResult.TOPIC_CAT));
        if (StringUtils.isNotBlank(metadataEl.getChildText("geoDescCode"))) {
            String locationUriString = "http://geodatastore.pdok.nl/registry/location#" + metadataEl.getChildText("geoDescCode");
            if (this.locationManager != null && this.locationThesaurus != null) {
                KeywordBean locBean = this.locationManager.getKeywordById(this.locationThesaurus, locationUriString);
                if (locBean != null) {
                    md.setLocationUri(locationUriString);
                    md.setLocation(locBean.getDefaultValue());
                }
            }
        }
        md.setLineage(metadataEl.getChildText("lineage"));
        // FIXME license, where is this stored?
        List<Element> legalConstraints = metadataEl.getChildren("legalConstraints");
        if (legalConstraints != null && legalConstraints.size() > 1) {
            // License should be in the second position
            md.setLicense(legalConstraints.get(1).getText());
        }
        String mdStatus = metadataEl.getChildText("mdStatus");
        if (mdStatus != null) {
            switch (mdStatus) {
                case Params.Status.DRAFT:
                    mdStatus = "draft";
                    break;
                case Params.Status.APPROVED:
                    mdStatus = "published";
                    break;
                case Params.Status.REJECTED:
                    mdStatus = "rejected";
                    break;
                case Params.Status.RETIRED:
                    mdStatus = "retired";
                    break;
                case Params.Status.SUBMITTED:
                    mdStatus = "submitted";
                    break;
                case Params.Status.UNKNOWN:
                    mdStatus = "unknown";
                    break;
                default:
            }
        }
        md.setStatus(mdStatus);

        if (metadataEl.getChild("denominator") != null) {
            md.setResolution(metadataEl.getChildText("denominator"));
        } else if (metadataEl.getChild("denominators") != null) {
            List<Element> denominatorsList = metadataEl.getChild("denominators").getChildren("denominator ");
            if (denominatorsList.size() > 0) {
                md.setResolution(denominatorsList.get(0).getText());
            }
        }


        String link = metadataEl.getChildText("link");
        if (link != null) {
            // link has this format
            // $title|$desc|$linkage|$protocol|$mimetype|$tPosition
            String[] linkComponents = link.split("\\|");
            if (linkComponents.length == 6 && "download".equals(linkComponents[3])) {
                md.setUrl(linkComponents[2]);
                md.setFileName(linkComponents[0]);
                md.setFileType(linkComponents[4]);
            }
        }
        String format = metadataEl.getChildText("format");
        if (StringUtils.isNotBlank(format)) {
            String type = MimetypesFileTypeMap.getDefaultFileTypeMap().getContentType(format);
            md.setFileType(type);
        }

        // ThumbnailURL
        List images = metadataEl.getChildren("image");
        if (images.size() > 0) {
            Element imageEl = (Element) images.get(0);
            String image = imageEl.getText();
            String[] imageComponents = image.split("\\|");
            if (imageComponents.length > 1) {
                md.setThumbnailUri(imageComponents[1]);
            } else if (imageComponents.length > 0) {
                md.setThumbnailUri(imageComponents[0]);
            } else {
                md.setThumbnailUri("../../catalog/views/geodatastore/images/no-thumbnail.png");
            }
        }

        String geoBox = metadataEl.getChildText("geoBox");
        if (geoBox != null && geoBox.split("\\|").length == 4) {
            String[] geoBoxComponents = geoBox.split("\\|");
            String westBoundLongitude = geoBoxComponents[0];
            String southBoundLatitude = geoBoxComponents[1];
            String eastBoundLongitude = geoBoxComponents[2];
            String northBoundLatitude = geoBoxComponents[3];
            // Wkt = POLYGON((x1 y1, x1 y2, x2 y2, x2 y1, x1 y1))
            String wkt = String.format("POLYGON((%s %s, %s %s, %s %s, %s %s, %s %s))",
                    westBoundLongitude, southBoundLatitude, // (x1 y1)
                    westBoundLongitude, northBoundLatitude, // (x1 y2)
                    eastBoundLongitude, northBoundLatitude, // (x2 y2)
                    eastBoundLongitude, southBoundLatitude, // (x2 y1)
                    westBoundLongitude, southBoundLatitude  // (x1, y1)
            );
            md.setExtent(wkt);
        }

        md.setpublishDate(metadataEl.getChildText("publicationDate"));

        Element geonetInfo = metadataEl.getChild("info", Geonet.Namespaces.GEONET);
        if (geonetInfo != null) {
            md.setIdentifier(geonetInfo.getChildText("uuid"));
            md.setChangeDate(geonetInfo.getChildText("changeDate"));
        }
        return md;
    }

    public void initFromSummary(Element summary) {
        if (summary != null && summary.getName().equals(Jeeves.Elem.RESPONSE)) {
            Element summaryEl = summary.getChild("summary");
            if (summaryEl != null) {
                int count = NumberUtils.toInt(summaryEl.getAttributeValue("count"));
                this.setCount(count);
            }
        }

    }
}
