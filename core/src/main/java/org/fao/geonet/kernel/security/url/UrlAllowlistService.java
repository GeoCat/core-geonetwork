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

import java.util.List;

/**
 * Decides whether the application may use a given URL.
 *
 * <p>Two kinds of caller:</p>
 * <ul>
 *   <li>a sink about to fetch a URL — {@link #assertAllowed(String, UrlScope)};</li>
 *   <li>validation and the administration test form — {@link #isAllowed(String, UrlScope)} and
 *       {@link #test(String, UrlScope)}.</li>
 * </ul>
 *
 * <p>Checks are off by default: with the feature disabled every URL is allowed, which is what an
 * upgraded catalogue sees until an administrator turns it on.</p>
 */
public interface UrlAllowlistService {

    /**
     * @return true when the URL may be used, or when checks are disabled. In audit mode this
     * returns true for a URL that would otherwise be refused, and logs it.
     */
    boolean isAllowed(String url, UrlScope scope);

    /**
     * @throws UrlNotAllowedException when {@link #isAllowed(String, UrlScope)} is false.
     */
    void assertAllowed(String url, UrlScope scope);

    /**
     * The real verdict, with its reason and the rule that matched — never softened by audit mode.
     */
    UrlCheckResult test(String url, UrlScope scope);

    /**
     * The rules that apply to a scope, in evaluation order.
     */
    List<UrlRule> getRules(UrlScope scope);
}
