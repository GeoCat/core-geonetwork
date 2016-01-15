package nl.kadaster.pdok.bussiness;

import nl.kadaster.pdok.bussiness.registryservices.RegistryService;

import java.util.List;

/**
 * Created by juanluisrp on 12/01/2016.
 */
public interface RegistryServiceLocator {
    RegistryService getService(String codelist);
    List<String> getAvailableCodelists();
}
