package nl.kadaster.pdok.bussiness.registryservices;

import nl.kadaster.pdok.bussiness.registryservices.bean.Location;
import org.fao.geonet.ApplicationContextHolder;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.kernel.KeywordBean;
import org.fao.geonet.kernel.Thesaurus;
import org.fao.geonet.kernel.ThesaurusManager;
import org.fao.geonet.kernel.search.KeywordsSearcher;
import org.fao.geonet.kernel.search.keyword.KeywordSearchParamsBuilder;
import org.fao.geonet.kernel.search.keyword.KeywordSearchType;
import org.fao.geonet.kernel.search.keyword.KeywordSort;
import org.fao.geonet.kernel.search.keyword.SortDirection;
import org.fao.geonet.languages.IsoLanguagesMapper;
import org.fao.geonet.utils.Log;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Created by JuanLuis on 18/01/2016.
 */
@Service
public class LocationRegistryService implements RegistryService {


    @Override
    public List<? extends CodelistElement> query(String q, Integer pageSize) {
        ConfigurableApplicationContext applicationContext = ApplicationContextHolder.get();
        List<Location> result = new ArrayList<>();


        KeywordsSearcher searcher;
           // perform the search and save search result into session
        ThesaurusManager thesaurusMan = applicationContext.getBean(ThesaurusManager.class);

            if(Log.isDebugEnabled("KeywordsManager")) {
                Log.debug("KeywordsManager","Creating new keywords searcher");
            }
            IsoLanguagesMapper languagesMapper = applicationContext.getBean(IsoLanguagesMapper.class);
            searcher = new KeywordsSearcher(languagesMapper, thesaurusMan);

            KeywordSearchParamsBuilder builder = createBuilderParams(languagesMapper, q, "dut", pageSize);

            if (q == null || q.trim().isEmpty()) {
                builder.setComparator(KeywordSort.defaultLabelSorter(SortDirection.DESC));
            } else {
                builder.setComparator(KeywordSort.searchResultsSorter(q, SortDirection.DESC));
            }

        try {
            searcher.search(builder.build());
            List<KeywordBean> keywords = searcher.getResults();
            for (KeywordBean keyword : keywords) {
                Location location = new Location(keyword);
                result.add(location);
            }
        } catch (Exception e) {
            e.printStackTrace();
            Log.error(LocationRegistryService.class.getName(), "Error searching location \"" + q + "\"", e);
        }

        return result;
    }

    private KeywordSearchParamsBuilder createBuilderParams (IsoLanguagesMapper mapper, String searchTerm, String uiLang,
                                                            Integer maxResults) {
        KeywordSearchParamsBuilder parsedParams = new KeywordSearchParamsBuilder(mapper).lenient(true);

        if(searchTerm != null) {
            KeywordSearchType searchType = KeywordSearchType.parseString("1");
            parsedParams.keyword(searchTerm, searchType, true);
        }

        if(maxResults != null) {
            parsedParams.maxResults(maxResults);
        }
        parsedParams.addThesaurus("external.place.administrativeAreas");

        parsedParams.addLang(uiLang);

        return parsedParams;

    }
}
