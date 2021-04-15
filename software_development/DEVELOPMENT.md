# Development

As described in the [overview](OVERVIEW.md) GeoNetwork is written is a Java application written using the spring framework to tie together a wide range of technologies.

This page looks at how these technologies are used in GeoNetwork. Where possible a code example is provided to cut-and-paste from, followed by a discussion.

## Java Formatting

```
    /**
     * Transformed harvest node.
     *
     * @param node harvest node
     * @return transformed harvest node
     * @throws Exception hmm
     */
    private Element transform(Element node) throws Exception {
        String type = node.getChildText("value");
        node = (Element) node.clone();
        return Xml.transform(node, xslPath.resolve(type + ".xsl"));
    }
```

The eclipse formatter `code_quality/formatter.xml` may be used by both Eclipse and IntelliJ:

* Classic Java code style
* Use 4 spaces for indenting (not tabs)
* `140` character line width

## Header

Generic Java header:

```
/*
 * Copyright (C) 2021 Food and Agriculture Organization of the
 * United Nations (FAO-UN), United Nations World Food Programme (WFP)
 * and United Nations Environment Programme (UNEP), and others.
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
```

Generic XML header
```
<!--
  ~ Copyright (C) 2021 Food and Agriculture Organization of the
  ~ United Nations (FAO-UN), United Nations World Food Programme (WFP)
  ~ and United Nations Environment Programme (UNEP)
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or (at
  ~ your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful, but
  ~ WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  ~ General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
  ~
  ~ Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
  ~ Rome - Italy. email: geonetwork@osgeo.org
  -->
```

The eclipse code template `code_quality/code_tempalte.xml` provided for Eclipse.

When creatinga new file:

* Indicate copyright with current year (when you are creating the file)/
  
  ```
  * Copyright (C) 2021 Food and Agriculture Organization of the
  * United Nations (FAO-UN), United Nations World Food Programme (WFP)
  * and United Nations Environment Programme (UNEP), and others.
  ```

* The party contributing (you or your employer) retain copyright:

  Represented as `,and others` in the copyright header above.
  
* Optional: As creator of the new file may explicitly state the party creating.
  
  ```
  * Copyright (C) 2021 Camptocamp, and others.
  ```
  
  Keep in mind most file copy-and-paste from existing GeoNetwork code, making the provided heaer apprpraite.

When updating a file no header change is required:

* The party contributing (you or your employer) retain copyright:

  Represented as `, and others` in the copyright boilerplate above.

* Optional:  Provide a date range when a file is updated over time:
  
  ```
  Copyright (C) 2019-2021
  ```

As an open source project GeoNetwork requires headers out of an abudance of caution, primarily to communicate GPL license on a file by file basis.

