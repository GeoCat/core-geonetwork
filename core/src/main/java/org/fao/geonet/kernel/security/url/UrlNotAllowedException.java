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

import org.fao.geonet.api.exception.NotAllowedException;

/**
 * Thrown when a URL is refused by the allowlist.
 *
 * <p>Unchecked on purpose: it has to propagate out of code that cannot declare it — in particular
 * the shared HTTP client in {@code common}, which is where redirect hops are checked — without
 * changing any signature.</p>
 *
 * <p>It extends {@link NotAllowedException}, which the API layer already maps to HTTP 403.</p>
 */
public class UrlNotAllowedException extends NotAllowedException {

    private final String url;
    private final UrlScope scope;

    public UrlNotAllowedException(String url, UrlScope scope, String reason) {
        super("URL '" + url + "' is not allowed for " + scope + ": " + reason);
        this.url = url;
        this.scope = scope;
    }

    public String getUrl() {
        return url;
    }

    public UrlScope getScope() {
        return scope;
    }
}
