package nl.kadaster.pdok.bussiness.registryservices;

import nl.kadaster.pdok.bussiness.registryservices.bean.License;
import org.apache.commons.lang.StringUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

/**
 * Created by JuanLuis on 15/01/2016.
 */
public abstract class AbstractInMemoryRegistryService implements RegistryService {
    protected Set<CodelistElement> codelistElementSet = new TreeSet<>();

    protected void addItem(CodelistElement element) {
        codelistElementSet.add(element);
    }

    @Override
    public List<? extends CodelistElement> query(String q, Integer pageSize) {
        int maxCount = pageSize;
        List<? extends CodelistElement> result = new ArrayList<>();
        if (pageSize == null || pageSize <= 0) {
            maxCount = DEFAULT_PAGE_SIZE;
        }
        if (StringUtils.isBlank(q)) {
            result = new ArrayList<>(codelistElementSet);
        } else {
            // TODO implement filtering
            result = new ArrayList<>(codelistElementSet);
        }

        return result;
    }


}
