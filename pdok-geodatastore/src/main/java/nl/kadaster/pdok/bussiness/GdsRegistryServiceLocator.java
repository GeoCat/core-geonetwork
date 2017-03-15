package nl.kadaster.pdok.bussiness;

import com.google.common.collect.ImmutableMap;
import nl.kadaster.pdok.bussiness.registryservices.RegistryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Created by juanluisrp on 12/01/2016.
 */
public class GdsRegistryServiceLocator implements RegistryServiceLocator{
    private Map<String, Class> registryServiceMap;
    @Autowired private ApplicationContext applicationContext;

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
        Class className = this.registryServiceMap.get(codelist);
        if (className == null) {
            return null;
        }
        Object serviceObject = applicationContext.getBean(className);
        if (serviceObject == null || ! RegistryService.class.isAssignableFrom(className)) {
            return null;
        }


        return (RegistryService) serviceObject;
    }

    @Override
    public List<String> getAvailableCodelists() {
        return new ArrayList<>(this.registryServiceMap.keySet());
    }
}
