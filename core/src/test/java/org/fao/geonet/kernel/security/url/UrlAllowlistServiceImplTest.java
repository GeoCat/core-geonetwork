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

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

/**
 * Matching and normalisation tests, including the bypasses a host allowlist is usually broken
 * with: userinfo, homographs, traversal, literal addresses and redirect-free scheme abuse.
 */
public class UrlAllowlistServiceImplTest {

    private UrlAllowlistServiceImpl service;

    @Before
    public void setUp() {
        service = new UrlAllowlistServiceImpl();
        service.setEnabled(true);
        service.setRules(Collections.singletonList(
            new UrlRule("example", "https://registry.example.org")));
    }

    private boolean allowed(String url) {
        return service.isAllowed(url, UrlScope.THESAURUS);
    }

    // --- the global switch -------------------------------------------------

    @Test
    public void disabledAllowsEverything() {
        service.setEnabled(false);
        assertTrue(allowed("https://evil.org/"));
        assertTrue(allowed("file:///etc/passwd"));
    }

    @Test
    public void enabledWithNoRulesDeniesEverything() {
        service.setRules(Collections.emptyList());
        assertFalse(allowed("https://registry.example.org/"));
    }

    @Test
    public void disabledRuleIsIgnored() {
        service.setRules(Collections.singletonList(
            new UrlRule("off", null, "https://registry.example.org", false)));
        assertFalse(allowed("https://registry.example.org/"));
    }

    // --- host matching -----------------------------------------------------

    @Test
    public void exactHostMatches() {
        assertTrue(allowed("https://registry.example.org/thesauri/rdf"));
        assertFalse(allowed("https://other.org/"));
    }

    @Test
    public void userinfoDoesNotImpersonateTheAllowedHost() {
        assertFalse(allowed("https://registry.example.org@evil.org/"));
    }

    @Test
    public void allowedHostInThePathDoesNotMatch() {
        assertFalse(allowed("https://evil.org/.registry.example.org/"));
    }

    @Test
    public void wildcardMatchesSubDomainsOnly() {
        service.setRules(Collections.singletonList(new UrlRule("sub", "https://*.example.org")));
        assertTrue(allowed("https://a.example.org/"));
        assertTrue(allowed("https://a.b.example.org/"));
        // no dot, so the wildcard cannot cover it
        assertFalse(allowed("https://evil-example.org/"));
        // the apex needs its own rule
        assertFalse(allowed("https://example.org/"));
    }

    @Test
    public void hostAndSchemeAreCaseInsensitiveAndDefaultPortIsImplicit() {
        assertTrue(allowed("HTTPS://Registry.Example.ORG:443/thesauri"));
    }

    @Test
    public void homographHostIsNotTheAllowedHost() {
        // first character is Cyrillic "а", not Latin "a"
        service.setRules(Collections.singletonList(new UrlRule("ascii", "https://allowed.org")));
        assertFalse(allowed("https://аllowed.org/"));
    }

    @Test
    public void unicodeHostMatchesItsPunycodeRule() {
        service.setRules(Collections.singletonList(
            new UrlRule("idn", "https://xn--bcher-kva.example.org")));
        assertTrue(allowed("https://bücher.example.org/"));
    }

    // --- scheme and port ---------------------------------------------------

    @Test
    public void schemesOutsideTheAllowlistAreRefusedEvenWhenAHostRuleMatches() {
        service.setRules(Collections.singletonList(new UrlRule("any", "*")));
        assertFalse(allowed("file:///etc/passwd"));
        assertFalse(allowed("ftp://registry.example.org/"));
        assertFalse(allowed("jar:https://registry.example.org/a.jar!/b"));
        assertTrue(allowed("https://registry.example.org/"));
    }

    @Test
    public void opaqueUrlIsRefused() {
        assertFalse(allowed("mailto:someone@example.org"));
    }

    @Test
    public void explicitPortMustMatch() {
        service.setRules(Collections.singletonList(
            new UrlRule("port", "https://registry.example.org:8443")));
        assertTrue(allowed("https://registry.example.org:8443/"));
        assertFalse(allowed("https://registry.example.org:9443/"));
        assertFalse(allowed("https://registry.example.org/"));
    }

    // --- path --------------------------------------------------------------

    @Test
    public void pathPrefixStopsOnSegmentBoundary() {
        service.setRules(Collections.singletonList(
            new UrlRule("path", "https://registry.example.org/thesauri")));
        assertTrue(allowed("https://registry.example.org/thesauri"));
        assertTrue(allowed("https://registry.example.org/thesauri/rdf"));
        assertFalse(allowed("https://registry.example.org/thesauri-private"));
        assertFalse(allowed("https://registry.example.org/admin"));
    }

    @Test
    public void traversalCannotClimbOutOfTheAllowedPath() {
        service.setRules(Collections.singletonList(
            new UrlRule("path", "https://registry.example.org/thesauri")));
        assertFalse(allowed("https://registry.example.org/thesauri/../admin"));
    }

    // --- internal addresses ------------------------------------------------

    @Test
    public void internalLiteralsAreRefusedEvenWhenARuleAllowsThem() {
        service.setRules(Arrays.asList(
            new UrlRule("metadata", "http://169.254.169.254"),
            new UrlRule("loopback", "http://127.0.0.1"),
            new UrlRule("private", "http://10.0.0.1"),
            new UrlRule("ipv6", "http://[::1]")));
        assertFalse(allowed("http://169.254.169.254/latest/meta-data/"));
        assertFalse(allowed("http://127.0.0.1:8080/"));
        assertFalse(allowed("http://10.0.0.1/"));
        assertFalse(allowed("http://[::1]/"));
        assertFalse(allowed("http://[::ffff:127.0.0.1]/"));
    }

    @Test
    public void internalLiteralsAreAllowedOnceTheOptOutIsSet() {
        service.setAllowInternalAddresses(true);
        service.setRules(Collections.singletonList(new UrlRule("intranet", "http://10.0.0.1")));
        assertTrue(allowed("http://10.0.0.1/"));
        // still subject to the rules
        assertFalse(allowed("http://10.0.0.2/"));
    }

    @Test
    public void publicLiteralIsMatchedNormally() {
        service.setRules(Collections.singletonList(new UrlRule("literal", "http://93.184.216.34")));
        assertTrue(allowed("http://93.184.216.34/"));
    }

    // --- malformed input ---------------------------------------------------

    @Test
    public void malformedInputIsRefused() {
        assertFalse(allowed(null));
        assertFalse(allowed(""));
        assertFalse(allowed("   "));
        assertFalse(allowed("https://registry.example.org/a b"));
        assertFalse(allowed("https://registry.example.org/\nHost: evil.org"));
        assertFalse(allowed("not a url"));
    }

    @Test(expected = IllegalArgumentException.class)
    public void invalidPatternIsRejectedWhenTheRuleIsBuilt() {
        new UrlRule("bad", "https://");
    }

    // --- audit mode and assertion ------------------------------------------

    @Test
    public void auditModeAllowsButStillReportsTheRealVerdict() {
        service.setAuditMode(true);
        assertTrue(allowed("https://evil.org/"));
        assertFalse(service.test("https://evil.org/", UrlScope.THESAURUS).isAllowed());
    }

    @Test
    public void resultNamesTheMatchingRule() {
        UrlCheckResult result = service.test("https://registry.example.org/", UrlScope.THESAURUS);
        assertTrue(result.isAllowed());
        assertEquals("example", result.getMatchedRule());
    }

    @Test
    public void assertAllowedCarriesTheUrlAndScope() {
        service.assertAllowed("https://registry.example.org/", UrlScope.THESAURUS);
        try {
            service.assertAllowed("https://evil.org/", UrlScope.HARVESTER);
            fail("expected UrlNotAllowedException");
        } catch (UrlNotAllowedException e) {
            assertEquals("https://evil.org/", e.getUrl());
            assertEquals(UrlScope.HARVESTER, e.getScope());
        }
    }
}
