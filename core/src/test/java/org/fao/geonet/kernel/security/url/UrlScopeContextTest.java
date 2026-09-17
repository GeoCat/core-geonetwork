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

import org.junit.After;
import org.junit.Test;

import static org.junit.Assert.assertEquals;

/**
 * A unit of work says which feature it is once; fetches that know their own scope are unaffected.
 */
public class UrlScopeContextTest {

    @After
    public void clear() {
        UrlScopeContext.clear();
    }

    @Test
    public void withoutAUnitOfWorkTheScopeIsTheCatalogueWideOne() {
        assertEquals(UrlScope.GLOBAL, UrlScopeContext.resolve(UrlScope.GLOBAL));
        assertEquals(UrlScope.GLOBAL, UrlScopeContext.resolve(null));
    }

    @Test
    public void aUnitOfWorkSuppliesTheScopeForWhoeverDoesNotKnowIt() {
        UrlScopeContext.set(UrlScope.HARVESTER);
        assertEquals(UrlScope.HARVESTER, UrlScopeContext.resolve(UrlScope.GLOBAL));
    }

    @Test
    public void acallerThatKnowsItsOwnScopeKeepsIt() {
        UrlScopeContext.set(UrlScope.HARVESTER);
        assertEquals(UrlScope.THESAURUS, UrlScopeContext.resolve(UrlScope.THESAURUS));
    }

    @Test
    public void clearingRestoresTheCatalogueWideScope() {
        UrlScopeContext.set(UrlScope.HARVESTER);
        UrlScopeContext.clear();
        assertEquals(UrlScope.GLOBAL, UrlScopeContext.resolve(UrlScope.GLOBAL));
    }

    @Test
    public void theScopeBelongsToOneThread() throws InterruptedException {
        UrlScopeContext.set(UrlScope.HARVESTER);
        UrlScope[] seen = new UrlScope[1];
        Thread other = new Thread(() -> seen[0] = UrlScopeContext.resolve(UrlScope.GLOBAL));
        other.start();
        other.join();
        assertEquals(UrlScope.GLOBAL, seen[0]);
    }
}
