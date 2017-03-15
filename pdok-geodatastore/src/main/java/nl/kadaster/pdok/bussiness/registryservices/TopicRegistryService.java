package nl.kadaster.pdok.bussiness.registryservices;

import nl.kadaster.pdok.bussiness.registryservices.bean.License;
import nl.kadaster.pdok.bussiness.registryservices.bean.TopicCategory;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Created by juanluisrp on 14/01/2016.
 */
@Service
public class TopicRegistryService extends AbstractInMemoryRegistryService implements RegistryService {

    public TopicRegistryService() {

        addTopic("imageryBaseMapsEarthCover", "Luchtfoto / Dekking van de Aarde");
        addTopic("inlandWaters", "Binnenwateren");
        addTopic("biota", "Biota (flora, fauna, habitat)");
        addTopic("economy", "Economie");
        addTopic("geoscientificInformation", "Geo-wetenschappelijke informatie");
        addTopic("health", "Gezondheid");
        addTopic("boundaries, ", "Grenzen");
        addTopic("intelligenceMilitary", "Inlichtingen / Defensie");
        addTopic("climatologyMeteorologyAtmosphere", "Klimatologie / Meteorologie");
        addTopic("farming", "Landbouw");
        addTopic("location", "Locatie");
        addTopic("society", "Maatschappij");
        addTopic("environment", "Milieu");
        addTopic("oceans", "Oceanen");
        addTopic("planningCadastre", "Planning / Kadaster");
        addTopic("structure", "Structuur");
        addTopic("utilitiesCommunication", "Nuts diensten / Communicatie");
        addTopic("elevation", "Hoogte");
        addTopic("transportation", "Vervoer");

    }

    private void addTopic(String key, String label) {
        TopicCategory topic = new TopicCategory();
        topic.setKey(key);
        topic.setLabel(label);
        addItem(topic);
    }



}
