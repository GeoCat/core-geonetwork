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

/**
 * The seam through which the shared HTTP client asks whether it may fetch a URL.
 *
 * <p>The allowlist itself lives in the core module, which this one cannot see, so the client holds
 * this interface instead and core installs the real implementation at start-up. Until it does —
 * and in any deployment that does not wire one — {@link #ALLOW_ALL} keeps the previous behaviour.
 * </p>
 *
 * <p>Implementations throw an unchecked exception to refuse a URL, so that no signature in this
 * module has to change.</p>
 */
@FunctionalInterface
public interface UrlAllowlistCheck {

    /**
     * The catalogue-wide scope, used wherever a fetch is not attached to a specific feature.
     */
    String SCOPE_GLOBAL = "GLOBAL";

    /**
     * Checks nothing, which is what an unconfigured catalogue does.
     */
    UrlAllowlistCheck ALLOW_ALL = (url, scope) -> {
    };

    /**
     * @throws RuntimeException when the URL may not be used.
     */
    void assertAllowed(String url, String scope);
}
