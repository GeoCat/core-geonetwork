package nl.kadaster.pdok.bussiness;

import com.google.common.collect.ImmutableMap;
import nl.kadaster.pdok.bussiness.registryservices.RegistryService;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Created by juanluisrp on 12/01/2016.
 */
public class GdsRegistryServiceLocator implements RegistryServiceLocator{
    private Map<String, Class> registryServiceMap;

    /**
     * Builds a new GdsRegistryServiceLocator
     * @param registryServiceMap a map that relates a key with the class that returns the codelist for the key (it must
     *                           implement RegistryService interface).
     */
    public GdsRegistryServiceLocator(Map<String, Class> registryServiceMap) {
        this.registryServiceMap = ImmutableMap.copyOf(registryServiceMap);
    }

    @Override
    public RegistryService getService(String codelist) {
        return null;
    }

    @Override
    public List<String> getAvailableCodelists() {
        return new ArrayList<>(this.registryServiceMap.keySet());
    }
}
