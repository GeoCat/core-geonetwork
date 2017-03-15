package nl.kadaster.pdok.bussiness;

import com.fasterxml.jackson.annotation.JsonRootName;
import nl.kadaster.pdok.bussiness.registryservices.Registry;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import java.util.List;

/**
 * Created by JuanLuis on 15/01/2016.
 */
@XmlRootElement(name = "registries")
@JsonRootName(value = "")
public class RegistryResponse {
    private List<Registry> registries;

    public RegistryResponse() {
    }

    public RegistryResponse(List<Registry> registries) {
        this.registries = registries;
    }

    @XmlElement(name = "registry")
    public List<Registry> getRegistries() {
        return registries;
    }

    public void setRegistries(List<Registry> registries) {
        this.registries = registries;
    }

}
