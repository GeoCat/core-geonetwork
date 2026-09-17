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

import org.jdom.Element;
import org.junit.After;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;

import java.io.File;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;

/**
 * Xml.loadFile reads both local files and remote documents through the same method. Only the
 * remote ones are URLs anyone supplied, and only those are checked.
 */
public class XmlUrlCheckTest {

    private static class Refused extends RuntimeException {
    }

    @Rule
    public TemporaryFolder folder = new TemporaryFolder();

    @After
    public void resetCheck() {
        UrlAllowlistChecks.set(UrlAllowlistCheck.ALLOW_ALL);
    }

    private void refuseEverything() {
        UrlAllowlistChecks.set((url, scope) -> {
            throw new Refused();
        });
    }

    @Test
    public void aLocalFileIsNotAnAllowlistedUrl() throws Exception {
        refuseEverything();
        File file = folder.newFile("record.xml");
        Files.write(file.toPath(), "<root><a/></root>".getBytes(StandardCharsets.UTF_8));

        Element loaded = Xml.loadFile(file.toURI().toURL());

        assertEquals("root", loaded.getName());
    }

    @Test
    public void aPackagedResourceIsNotAnAllowlistedUrlEither() throws Exception {
        refuseEverything();
        URL packaged = getClass().getResource("/org/fao/geonet/utils/xmltest/sampleXml.xml");

        // a schema or a template read off the classpath is not a URL anyone supplied
        Xml.loadFile(packaged);
    }

    @Test
    public void aRemoteDocumentIsChecked() throws Exception {
        refuseEverything();
        try {
            // nothing listens on this port: reaching the network at all would be an IOException
            Xml.loadFile(new URL("http://localhost:9/record.xml"));
            fail("expected the document to be refused");
        } catch (Refused expected) {
            // the check ran before anything was opened
        }
    }

    @Test
    public void thePostVariantIsCheckedToo() throws Exception {
        refuseEverything();
        try {
            Xml.loadFile(new URL("http://localhost:9/csw"), new Element("GetRecords"));
            fail("expected the request to be refused");
        } catch (Refused expected) {
            // as above
        }
    }
}
