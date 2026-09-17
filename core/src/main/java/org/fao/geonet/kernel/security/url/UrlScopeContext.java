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

/**
 * The feature the current thread is working for.
 *
 * <p>Most fetches go through the shared HTTP client, which has no idea which feature asked: adding
 * a scope to every call would mean changing every caller in half the code base. A feature that
 * runs as a unit of work instead says so once, around that work, and everything it fetches is
 * checked as that feature.</p>
 *
 * <p>A caller that does know its own scope passes it explicitly and is unaffected by this.</p>
 */
public final class UrlScopeContext {

    private static final ThreadLocal<UrlScope> CURRENT = new ThreadLocal<>();

    private UrlScopeContext() {
    }

    /**
     * @return the scope to check with: the one asked for, unless it is the catalogue-wide default
     * and the thread is working for a particular feature.
     */
    public static UrlScope resolve(UrlScope requested) {
        if (requested != null && requested != UrlScope.GLOBAL) {
            return requested;
        }
        UrlScope current = CURRENT.get();
        return current == null ? UrlScope.GLOBAL : current;
    }

    /**
     * Always paired with {@link #clear()} in a finally block: the thread is returned to a pool.
     */
    public static void set(UrlScope scope) {
        CURRENT.set(scope);
    }

    public static void clear() {
        CURRENT.remove();
    }
}
