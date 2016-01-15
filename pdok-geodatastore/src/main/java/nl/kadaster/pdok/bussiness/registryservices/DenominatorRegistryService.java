package nl.kadaster.pdok.bussiness.registryservices;

import nl.kadaster.pdok.bussiness.registryservices.bean.Denominator;

import java.util.Set;
import java.util.TreeSet;

/**
 * Created by juanluisrp on 12/01/2016.
 */
public class DenominatorRegistryService implements RegistryService {
    private Set<Denominator> denominatorSortedSet = new TreeSet<>();

    public DenominatorRegistryService() {
        addElement("1000000", "1:1.000.000");
        addElement("250000", "1:250.000");
        addElement("100000", "1:100.000");
        addElement("25000", "1:25.000");
        addElement("10000", "1:10.000");
        addElement("2500", "1:2.500");
        addElement("1000", "1:1.000");
    }

    private void addElement(String key, String label) {
        Denominator denom = new Denominator();
        denom.setKey(key);
        denom.setLabel(label);
        denominatorSortedSet.add(denom);

    }
}
