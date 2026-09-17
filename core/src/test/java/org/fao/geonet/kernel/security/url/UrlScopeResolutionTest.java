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

import org.junit.Before;
import org.junit.Test;

import java.util.Arrays;
import java.util.Collections;
import java.util.EnumMap;
import java.util.Map;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

/**
 * How a feature's mode decides which rules it evaluates.
 */
public class UrlScopeResolutionTest {

    private UrlAllowlistServiceImpl service;

    @Before
    public void setUp() {
        service = new UrlAllowlistServiceImpl();
        service.setEnabled(true);
        service.setRules(Arrays.asList(
            new UrlRule("global", null, "https://shared.example.org", true, UrlScope.GLOBAL),
            new UrlRule("harvest", null, "https://harvest.example.org", true, UrlScope.HARVESTER),
            new UrlRule("doi", null, "https://doi.example.org", true, UrlScope.DOI)));
    }

    private void mode(UrlScope scope, UrlScopeMode mode) {
        Map<UrlScope, UrlScopeMode> modes = new EnumMap<>(UrlScope.class);
        modes.put(scope, mode);
        service.setModes(modes);
    }

    @Test
    public void inheritIsTheDefaultAndSeesOnlyTheGlobalRules() {
        assertEquals(UrlScopeMode.INHERIT, service.getMode(UrlScope.HARVESTER));
        assertTrue(service.isAllowed("https://shared.example.org/", UrlScope.HARVESTER));
        // its own rule is not visible until the mode says so
        assertFalse(service.isAllowed("https://harvest.example.org/", UrlScope.HARVESTER));
    }

    @Test
    public void extendSeesBoth() {
        mode(UrlScope.HARVESTER, UrlScopeMode.EXTEND);
        assertTrue(service.isAllowed("https://shared.example.org/", UrlScope.HARVESTER));
        assertTrue(service.isAllowed("https://harvest.example.org/", UrlScope.HARVESTER));
        assertFalse(service.isAllowed("https://doi.example.org/", UrlScope.HARVESTER));
    }

    @Test
    public void overrideDropsTheGlobalRules() {
        mode(UrlScope.HARVESTER, UrlScopeMode.OVERRIDE);
        assertFalse(service.isAllowed("https://shared.example.org/", UrlScope.HARVESTER));
        assertTrue(service.isAllowed("https://harvest.example.org/", UrlScope.HARVESTER));
    }

    @Test
    public void disabledChecksNothingForThatScopeOnly() {
        mode(UrlScope.HARVESTER, UrlScopeMode.DISABLED);
        assertTrue(service.isAllowed("https://anywhere.example.org/", UrlScope.HARVESTER));
        assertFalse(service.isAllowed("https://anywhere.example.org/", UrlScope.DOI));
    }

    @Test
    public void aModeOnOneScopeLeavesTheOthersAlone() {
        mode(UrlScope.HARVESTER, UrlScopeMode.OVERRIDE);
        assertTrue(service.isAllowed("https://shared.example.org/", UrlScope.THESAURUS));
        assertFalse(service.isAllowed("https://harvest.example.org/", UrlScope.THESAURUS));
    }

    @Test
    public void theGlobalScopeHasNoModeOfItsOwn() {
        mode(UrlScope.GLOBAL, UrlScopeMode.DISABLED);
        assertEquals(UrlScopeMode.INHERIT, service.getMode(UrlScope.GLOBAL));
        assertFalse(service.isAllowed("https://harvest.example.org/", UrlScope.GLOBAL));
    }

    @Test
    public void implicitRulesSurviveEveryMode() {
        service.setImplicitRules(Collections.singletonList(
            new UrlRule("catalogue", "http://localhost:8080")));
        for (UrlScopeMode m : new UrlScopeMode[]{UrlScopeMode.INHERIT, UrlScopeMode.EXTEND,
            UrlScopeMode.OVERRIDE}) {
            mode(UrlScope.HARVESTER, m);
            assertTrue("catalogue unreachable on " + m,
                service.isAllowed("http://localhost:8080/srv/api/site", UrlScope.HARVESTER));
        }
    }

    @Test
    public void theResultNamesTheScopeOfTheRuleThatMatched() {
        mode(UrlScope.HARVESTER, UrlScopeMode.EXTEND);
        UrlCheckResult result = service.test("https://harvest.example.org/", UrlScope.HARVESTER);
        assertEquals("harvest", result.getMatchedRule());
        assertTrue(result.getReason(), result.getReason().contains("HARVESTER"));
    }
}
