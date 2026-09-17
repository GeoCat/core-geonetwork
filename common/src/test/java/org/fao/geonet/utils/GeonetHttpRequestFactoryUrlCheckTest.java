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

package org.fao.geonet.utils;

import org.apache.http.HttpVersion;
import org.apache.http.ProtocolException;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.protocol.HttpClientContext;
import org.apache.http.message.BasicHttpResponse;
import org.apache.http.message.BasicStatusLine;
import org.apache.http.protocol.HttpCoreContext;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.io.IOException;
import java.net.URI;
import java.util.ArrayList;
import java.util.List;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

/**
 * The client has to ask before it opens anything, and again for every redirect hop.
 */
public class GeonetHttpRequestFactoryUrlCheckTest {

    private static class Refused extends RuntimeException {
        Refused(String url) {
            super("refused " + url);
        }
    }

    private GeonetHttpRequestFactory factory;
    private List<String> checked;

    @Before
    public void setUp() {
        factory = new GeonetHttpRequestFactory();
        checked = new ArrayList<>();
    }

    private void refuse(String refusedHost) {
        factory.setUrlAllowlistCheck((url, scope) -> {
            checked.add(url + " [" + scope + "]");
            if (url.contains(refusedHost)) {
                throw new Refused(url);
            }
        });
    }

    @After
    public void resetSharedCheck() {
        UrlAllowlistChecks.set(UrlAllowlistCheck.ALLOW_ALL);
    }

    @Test
    public void theSharedCheckAppliesWithoutBeingSetOnTheInstance() {
        UrlAllowlistChecks.set((url, scope) -> {
            throw new Refused(url);
        });
        try {
            new GeonetHttpRequestFactory().execute(new HttpGet("http://evil.org:9/nothing"));
            fail("expected the request to be refused");
        } catch (Refused expected) {
            // the catalogue installs one check for everything that has no bean to inject
        } catch (IOException e) {
            fail("the request was attempted instead of being refused: " + e);
        }
    }

    @Test
    public void refusedUrlNeverReachesTheNetwork() {
        refuse("evil.org");
        try {
            // a port nothing listens on: if the check did not run first, this fails as an IOException
            factory.execute(new HttpGet("http://evil.org:9/nothing"));
            fail("expected the request to be refused");
        } catch (Refused e) {
            assertEquals(1, checked.size());
            assertTrue(checked.get(0).startsWith("http://evil.org:9/nothing"));
        } catch (IOException e) {
            fail("the request was attempted instead of being refused: " + e);
        }
    }

    @Test
    public void theCheckSeesTheWholeUrlAndAScope() throws IOException {
        refuse("evil.org");
        try {
            factory.execute(new HttpGet("https://evil.org/a?b=c"));
            fail("expected the request to be refused");
        } catch (Refused e) {
            assertEquals("https://evil.org/a?b=c [GLOBAL]", checked.get(0));
        }
    }

    @Test
    public void redirectToARefusedHostIsStopped() throws ProtocolException {
        refuse("evil.org");
        try {
            redirectTo("https://evil.org/landing");
            fail("expected the redirect to be refused");
        } catch (Refused e) {
            assertEquals("https://evil.org/landing [GLOBAL]", checked.get(0));
        }
    }

    @Test
    public void redirectToAnAllowedHostIsFollowed() throws ProtocolException {
        refuse("evil.org");
        assertEquals(URI.create("https://allowed.org/elsewhere"), redirectTo("https://allowed.org/elsewhere"));
    }

    private URI redirectTo(String location) throws ProtocolException {
        HttpGet request = new HttpGet("https://allowed.org/");
        BasicHttpResponse response = new BasicHttpResponse(
            new BasicStatusLine(HttpVersion.HTTP_1_1, 302, "Found"));
        response.addHeader("Location", location);
        HttpClientContext context = HttpClientContext.create();
        context.setAttribute(HttpCoreContext.HTTP_REQUEST, request);
        return factory.createRedirectStrategy().getLocationURI(request, response, context);
    }
}
