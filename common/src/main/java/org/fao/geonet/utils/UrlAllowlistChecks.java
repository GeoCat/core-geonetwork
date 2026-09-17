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
 * Where code that has no bean to inject finds the URL allowlist.
 *
 * <p>The allowlist lives in the core module and is installed here at start-up. Until it is, and in
 * a deployment that never installs one, {@link UrlAllowlistCheck#ALLOW_ALL} keeps the previous
 * behaviour.</p>
 */
public final class UrlAllowlistChecks {

    private static volatile UrlAllowlistCheck check = UrlAllowlistCheck.ALLOW_ALL;

    private UrlAllowlistChecks() {
    }

    public static UrlAllowlistCheck get() {
        return check;
    }

    public static void set(UrlAllowlistCheck check) {
        UrlAllowlistChecks.check = check == null ? UrlAllowlistCheck.ALLOW_ALL : check;
    }
}
