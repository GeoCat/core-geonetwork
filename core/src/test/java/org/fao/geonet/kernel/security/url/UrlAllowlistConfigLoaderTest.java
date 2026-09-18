/*
 * Copyright (C) 2001-2026 Food and Agriculture Organization of the
 * United Nations (FAO-UN), United Nations World Food Programme (WFP)
 * and United Nations Environment Programme (UNEP)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 *
 * Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
 * Rome - Italy. email: geonetwork@osgeo.org
 */

package org.fao.geonet.kernel.security.url;

import org.fao.geonet.domain.Setting;
import org.fao.geonet.domain.UrlAllowlistRule;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.kernel.setting.Settings;
import org.fao.geonet.repository.UrlAllowlistRuleRepository;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mockito;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

/**
 * The loader turns stored rows into a usable configuration, and has to survive a row it cannot
 * compile.
 */
public class UrlAllowlistConfigLoaderTest {

    /**
     * A concrete class cannot be mocked on every JDK, and only one method is needed.
     */
    private static class StubSettingManager extends SettingManager {
        private final Map<String, Boolean> values = new HashMap<>();
        private final Map<String, String> strings = new HashMap<>();
        private final List<Setting> all = new ArrayList<>();
        private String baseUrl = "";

        @Override
        public List<Setting> getAll() {
            return all;
        }

        @Override
        public boolean setValue(String key, String value) {
            strings.put(key, value);
            return true;
        }

        @Override
        public boolean setValue(String key, boolean value) {
            values.put(key, value);
            strings.put(key, String.valueOf(value));
            return true;
        }

        @Override
        public boolean getValueAsBool(String key, boolean defaultValue) {
            return values.getOrDefault(key, defaultValue);
        }

        @Override
        public String getBaseURL() {
            return baseUrl;
        }

        @Override
        public String getValue(String path) {
            return strings.get(path);
        }
    }

    private StubSettingManager settingManager;
    private UrlAllowlistRuleRepository repository;
    private UrlAllowlistServiceImpl service;
    private UrlAllowlistConfigLoader loader;

    private static UrlAllowlistRule rule(String name, String pattern, boolean enabled) {
        return new UrlAllowlistRule().setName(name).setPattern(pattern).setEnabled(enabled)
            .setScope(UrlAllowlistRule.SCOPE_GLOBAL);
    }

    @Before
    public void setUp() {
        settingManager = new StubSettingManager();
        repository = Mockito.mock(UrlAllowlistRuleRepository.class);
        service = new UrlAllowlistServiceImpl();
        loader = new UrlAllowlistConfigLoader();
        ReflectionTestUtils.setField(loader, "settingManager", settingManager);
        ReflectionTestUtils.setField(loader, "ruleRepository", repository);
        ReflectionTestUtils.setField(loader, "service", service);

        settingManager.values.put(Settings.SYSTEM_URLALLOWLIST_ENABLED, true);
        Mockito.when(repository.findAllByOrderByNameAsc()).thenReturn(Collections.emptyList());
    }

    @Test
    public void settingsReachTheService() {
        settingManager.values.put(Settings.SYSTEM_URLALLOWLIST_AUDITMODE, true);
        settingManager.values.put(Settings.SYSTEM_URLALLOWLIST_ALLOWINTERNALADDRESSES, true);

        loader.reload();

        assertTrue(service.isEnabled());
        assertTrue(service.isAuditMode());
        assertTrue(service.isAllowInternalAddresses());
    }

    @Test
    public void storedRulesBecomeMatchingRules() {
        Mockito.when(repository.findAllByOrderByNameAsc()).thenReturn(Collections.singletonList(
            rule("registry", "https://registry.example.org", true)));

        loader.reload();

        assertEquals(1, service.getRules(UrlScope.GLOBAL).size());
        assertTrue(service.isAllowed("https://registry.example.org/rdf", UrlScope.THESAURUS));
        assertFalse(service.isAllowed("https://evil.org/", UrlScope.THESAURUS));
    }

    @Test
    public void anUnusableRuleIsDroppedAndTheRestStillLoad() {
        Mockito.when(repository.findAllByOrderByNameAsc()).thenReturn(Arrays.asList(
            rule("broken", "https://", true),
            rule("registry", "https://registry.example.org", true)));

        loader.reload();

        assertEquals(1, service.getRules(UrlScope.GLOBAL).size());
        assertTrue(service.isAllowed("https://registry.example.org/", UrlScope.THESAURUS));
    }

    @Test
    public void theCatalogueIsAllowedToReachItself() {
        settingManager.baseUrl = "http://localhost:8080/geonetwork/";

        loader.reload();

        assertTrue(service.isAllowed("http://localhost:8080/geonetwork/srv/api/site", UrlScope.GLOBAL));
        assertFalse(service.isAllowed("http://localhost:9090/geonetwork/", UrlScope.GLOBAL));
        assertEquals("catalogue", service.test("http://localhost:8080/", UrlScope.GLOBAL).getMatchedRule());
    }

    @Test
    public void anUnparseableBaseUrlIsSurvivable() {
        settingManager.baseUrl = ":::not a url";

        loader.reload();

        assertTrue(service.getRules(UrlScope.GLOBAL).isEmpty());
    }

    @Test
    public void scopeModesAreReadFromTheSetting() {
        settingManager.strings.put(Settings.SYSTEM_URLALLOWLIST_SCOPEMODES,
            "{\"HARVESTER\":\"OVERRIDE\",\"DOI\":\"DISABLED\"}");
        Mockito.when(repository.findAllByOrderByNameAsc()).thenReturn(Collections.singletonList(
            rule("registry", "https://registry.example.org", true)));

        loader.reload();

        assertEquals(UrlScopeMode.OVERRIDE, service.getMode(UrlScope.HARVESTER));
        assertEquals(UrlScopeMode.DISABLED, service.getMode(UrlScope.DOI));
        assertEquals(UrlScopeMode.INHERIT, service.getMode(UrlScope.THESAURUS));
        // OVERRIDE with no rule of its own refuses everything, DISABLED refuses nothing
        assertFalse(service.isAllowed("https://registry.example.org/", UrlScope.HARVESTER));
        assertTrue(service.isAllowed("https://anywhere.example.org/", UrlScope.DOI));
        assertTrue(service.isAllowed("https://registry.example.org/", UrlScope.THESAURUS));
    }

    @Test
    public void unusableScopeModesLeaveEveryFeatureInheriting() {
        settingManager.strings.put(Settings.SYSTEM_URLALLOWLIST_SCOPEMODES, "not json");
        Mockito.when(repository.findAllByOrderByNameAsc()).thenReturn(Collections.singletonList(
            rule("registry", "https://registry.example.org", true)));

        loader.reload();

        assertEquals(UrlScopeMode.INHERIT, service.getMode(UrlScope.HARVESTER));
        assertTrue(service.isAllowed("https://registry.example.org/", UrlScope.HARVESTER));
    }

    @Test
    public void aRuleStoredForAFeatureIsLoadedWithThatScope() {
        settingManager.strings.put(Settings.SYSTEM_URLALLOWLIST_SCOPEMODES,
            "{\"HARVESTER\":\"EXTEND\"}");
        UrlAllowlistRule stored = rule("harvest", "https://harvest.example.org", true)
            .setScope("HARVESTER");
        Mockito.when(repository.findAllByOrderByNameAsc()).thenReturn(Collections.singletonList(stored));

        loader.reload();

        assertTrue(service.isAllowed("https://harvest.example.org/", UrlScope.HARVESTER));
        assertFalse(service.isAllowed("https://harvest.example.org/", UrlScope.THESAURUS));
    }

    @Test
    public void theThesaurusAllowlistOf44xIsCarriedOver() {
        settingManager.all.add(new Setting().setName("system/metadata/thesaurusUrlAllowlist")
            .setValue("https://registry.example.org https://*.thesauri.example.org"));
        List<UrlAllowlistRule> saved = new ArrayList<>();
        Mockito.when(repository.save(Mockito.any(UrlAllowlistRule.class)))
            .thenAnswer(call -> {
                saved.add(call.getArgument(0));
                return call.getArgument(0);
            });

        loader.migrateLegacyAllowlist();

        // the two patterns, plus the rule that keeps the rest of the catalogue working
        assertEquals(3, saved.size());
        assertEquals("THESAURUS", saved.get(0).getScope());
        assertEquals("https://registry.example.org", saved.get(0).getPattern());
        assertEquals("https://*.thesauri.example.org", saved.get(1).getPattern());
        assertEquals("everything", saved.get(2).getName());
        assertEquals("*", saved.get(2).getPattern());
        assertEquals("GLOBAL", saved.get(2).getScope());

        // the protection is kept, and nothing else becomes restricted
        assertEquals("true", settingManager.strings.get(Settings.SYSTEM_URLALLOWLIST_ENABLED));
        String modes = settingManager.strings.get(Settings.SYSTEM_URLALLOWLIST_SCOPEMODES);
        assertTrue(modes, modes.contains("\"THESAURUS\":\"OVERRIDE\""));
        assertTrue(modes, modes.contains("\"LINK_CHECKER\":\"DISABLED\""));

        // and it does not run twice
        assertEquals("", settingManager.strings.get("system/metadata/thesaurusUrlAllowlist"));
    }

    @Test
    public void withoutALegacyAllowlistNothingIsTouched() {
        settingManager.all.add(new Setting().setName("system/metadata/thesaurusNamespace")
            .setValue("https://example.org/{{type}}"));

        loader.migrateLegacyAllowlist();

        Mockito.verify(repository, Mockito.never()).save(Mockito.any(UrlAllowlistRule.class));
        assertEquals(null, settingManager.strings.get(Settings.SYSTEM_URLALLOWLIST_ENABLED));
    }

    @Test
    public void reloadReplacesThePreviousConfiguration() {
        Mockito.when(repository.findAllByOrderByNameAsc()).thenReturn(Collections.singletonList(
            rule("registry", "https://registry.example.org", true)));
        loader.reload();
        assertTrue(service.isAllowed("https://registry.example.org/", UrlScope.THESAURUS));

        Mockito.when(repository.findAllByOrderByNameAsc()).thenReturn(Collections.emptyList());
        loader.reload();
        assertFalse(service.isAllowed("https://registry.example.org/", UrlScope.THESAURUS));
    }
}
