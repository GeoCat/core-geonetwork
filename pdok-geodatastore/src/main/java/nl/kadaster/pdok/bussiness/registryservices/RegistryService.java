package nl.kadaster.pdok.bussiness.registryservices;

import java.util.List;

/**
 * Created by juanluisrp on 12/01/2016.
 */
public interface RegistryService {
    /**
     * Default page size.
     */
    int DEFAULT_PAGE_SIZE = 200;

    /**
     * Return the list of items that match with the query string for the codelist.
     * @param q the filter. If null or blank it is not applied
     * @param pageSize maximum number of returned elements.
     * @return the list of items matching the query.
     */
    List<? extends CodelistElement> query(String q, Integer pageSize);
}
