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

import javax.persistence.Access;
import javax.persistence.AccessType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

/**
 * One entry of the URL allowlist: a pattern the application is allowed to reach, and the feature
 * it applies to.
 *
 * <p>The scope is kept as a string rather than an enum because the enum lives in the core module,
 * which this one cannot see. It is validated where rules are created.</p>
 */
@Entity
@Table(name = "UrlAllowlistRules")
@Access(AccessType.PROPERTY)
@SequenceGenerator(name = UrlAllowlistRule.ID_SEQ_NAME, initialValue = 100, allocationSize = 1)
public class UrlAllowlistRule extends GeonetEntity {

    static final String ID_SEQ_NAME = "url_allowlist_rule_id_seq";

    /**
     * The scope every rule gets until per-feature scopes are configurable.
     */
    public static final String SCOPE_GLOBAL = "GLOBAL";

    private int id;
    private String name;
    private String description;
    private String pattern;
    private String scope = SCOPE_GLOBAL;
    private boolean enabled = true;

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = ID_SEQ_NAME)
    @Column(nullable = false)
    public int getId() {
        return id;
    }

    public UrlAllowlistRule setId(int id) {
        this.id = id;
        return this;
    }

    @Column(nullable = false, length = 64)
    public String getName() {
        return name;
    }

    public UrlAllowlistRule setName(String name) {
        this.name = name;
        return this;
    }

    @Column(length = 255)
    public String getDescription() {
        return description;
    }

    public UrlAllowlistRule setDescription(String description) {
        this.description = description;
        return this;
    }

    /**
     * The pattern, as [scheme://]host[:port][/path] with * wildcards.
     */
    @Column(nullable = false, length = 512)
    public String getPattern() {
        return pattern;
    }

    public UrlAllowlistRule setPattern(String pattern) {
        this.pattern = pattern;
        return this;
    }

    @Column(nullable = false, length = 32)
    public String getScope() {
        return scope;
    }

    public UrlAllowlistRule setScope(String scope) {
        this.scope = scope;
        return this;
    }

    @Column(nullable = false)
    public boolean isEnabled() {
        return enabled;
    }

    public UrlAllowlistRule setEnabled(boolean enabled) {
        this.enabled = enabled;
        return this;
    }
}
