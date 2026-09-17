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

import org.fao.geonet.domain.UrlAllowlistRule;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.kernel.setting.Settings;
import org.fao.geonet.repository.UrlAllowlistRuleRepository;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mockito;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.Arrays;
import java.util.Collections;
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

        @Override
        public boolean getValueAsBool(String key, boolean defaultValue) {
            return values.getOrDefault(key, defaultValue);
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
