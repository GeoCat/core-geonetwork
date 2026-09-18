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

package org.fao.geonet.domain;

import org.junit.Test;

import static org.junit.Assert.assertEquals;

/**
 * The URL allowlist ruleset is a warning rather than an error, and that is decided by its file
 * name. Renaming the file would quietly turn every unlisted online resource into a validation
 * error, so the contract is pinned here.
 */
public class UrlAllowlistSchematronNamingTest {

    private static final String FILE = "schematron-rules-url-allowlist.report_only.xsl";

    @Test
    public void theRulesetIsAWarning() {
        Schematron schematron = new Schematron();
        schematron.setFile(FILE);

        assertEquals(SchematronRequirement.REPORT_ONLY, schematron.getDefaultRequirement());
    }

    @Test
    public void theRuleNameIsWhatTheLabelFilesAreNamedAfter() {
        Schematron schematron = new Schematron();
        schematron.setFile(FILE);

        // loc/<lang>/schematron-rules-url-allowlist.xml
        assertEquals("schematron-rules-url-allowlist", schematron.getRuleName());
    }
}
