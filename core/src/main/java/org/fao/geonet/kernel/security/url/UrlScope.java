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
 * The feature a URL check is made on behalf of.
 *
 * <p>The scope is passed by every caller from the start, even though only the global rule list is
 * configurable today: adding the parameter later would mean touching every call site in
 * {@code common}, {@code core}, {@code services}, {@code harvesters}, {@code doi} and {@code web}
 * a second time.</p>
 *
 * <p>Per-scope modes ({@code INHERIT} / {@code EXTEND} / {@code OVERRIDE} / {@code DISABLED}) are
 * added later; until then {@link UrlAllowlistServiceImpl} resolves every scope to the global
 * list.</p>
 */
public enum UrlScope {
    /**
     * The catalogue-wide list, and the fallback for every other scope.
     */
    GLOBAL,
    HARVESTER,
    DOI,
    MAPSERVER,
    THESAURUS,
    /**
     * Attachments uploaded from a URL by an editor.
     */
    EDITOR_UPLOAD,
    /**
     * Online resource URLs stored in a record. Checked by validation only, never blocking a save.
     */
    ONLINE_RESOURCE,
    /**
     * The link checker, which fetches whatever records point at to see whether it answers.
     */
    LINK_CHECKER,
    XLINK,
    /**
     * The client-side proxy servlet.
     */
    PROXY,
    FORMATTER
}
