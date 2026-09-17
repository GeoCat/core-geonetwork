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

import org.fao.geonet.ApplicationContextHolder;
import org.springframework.context.ApplicationContext;

/**
 * The allowlist, for the places that fetch a URL without a bean to inject: static helpers, XSLT
 * extensions and the like.
 *
 * <p>When there is no application context, or no allowlist in it, nothing is checked — the same
 * default the rest of this feature uses, so that a partially built context or a unit test behaves
 * as it did before.</p>
 */
public final class UrlAllowlist {

    private UrlAllowlist() {
    }

    /**
     * @throws UrlNotAllowedException when the catalogue may not fetch this URL.
     */
    public static void assertAllowed(String url, UrlScope scope) {
        UrlAllowlistService service = service();
        if (service != null) {
            service.assertAllowed(url, scope);
        }
    }

    private static UrlAllowlistService service() {
        try {
            ApplicationContext context = ApplicationContextHolder.get();
            return context == null ? null : context.getBean(UrlAllowlistService.class);
        } catch (Exception e) {
            return null;
        }
    }
}
