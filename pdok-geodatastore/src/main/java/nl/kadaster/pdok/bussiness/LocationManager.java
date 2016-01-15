package nl.kadaster.pdok.bussiness;

import org.fao.geonet.kernel.KeywordBean;
import org.fao.geonet.kernel.ThesaurusManager;
import org.fao.geonet.kernel.search.KeywordsSearcher;
import org.fao.geonet.languages.IsoLanguagesMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * Search locations in the indicated thesaurus.
 */
@Service
public class LocationManager {

    private String defaultLanguage;
    @Autowired
    private ThesaurusManager thesaurusMan;
    @Autowired
    private IsoLanguagesMapper languagesMapper;

    public String getDefaultLanguage() {
        return defaultLanguage;
    }

    @Value("#{geodatastoreProperties[defaultLanguage]}")
    public void setDefaultLanguage(String defaultLanguage) {
        this.defaultLanguage = defaultLanguage;
    }

    /**
     * Search a location in the indicated thesaurus.
     *
     * @param thesaurusName the name of the thesaurus.
     * @param language      the language to use in the search. Must be a ISO639 three letters code.
     * @param keywordId     the keyword id
     * @return a KeywordBean with the keyword details or <code>null</code> if keywordId cannot be found for the
     * thesaurus and language.
     */
    public KeywordBean getKeywordById(String thesaurusName, String language, String keywordId) {
        String twoLettersCode = languagesMapper.iso639_2_to_iso639_1(language, language.substring(0, 2));
        KeywordsSearcher searcher = new KeywordsSearcher(languagesMapper, thesaurusMan);
        return searcher.searchById(keywordId, thesaurusName, twoLettersCode);

    }

    /**
     * Search a location in the indicated thesaurus and default language.
     *
     * @param thesaurusName the name of the thesaurus.
     * @param keywordId     the keyword id
     * @return a KeywordBean with the keyword details or <code>null</code> if keywordId cannot be found for the
     * thesaurus and default language.
     */
    public KeywordBean getKeywordById(String thesaurusName, String keywordId) {
        return getKeywordById(thesaurusName, defaultLanguage, keywordId);
    }


}
