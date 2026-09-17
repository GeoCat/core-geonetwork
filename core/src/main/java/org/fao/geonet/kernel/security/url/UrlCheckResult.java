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
 * The outcome of a single URL check: the verdict, why, and which rule decided it.
 *
 * <p>This is what the administration "test a URL" form reports, so it always carries the real
 * verdict — audit mode is applied by {@link UrlAllowlistService#isAllowed(String, UrlScope)}, not
 * here.</p>
 */
public class UrlCheckResult {

    private final boolean allowed;
    private final String reason;
    private final String matchedRule;

    private UrlCheckResult(boolean allowed, String reason, String matchedRule) {
        this.allowed = allowed;
        this.reason = reason;
        this.matchedRule = matchedRule;
    }

    public static UrlCheckResult allowed(String reason) {
        return new UrlCheckResult(true, reason, null);
    }

    public static UrlCheckResult allowedBy(UrlRule rule) {
        return new UrlCheckResult(true,
            "matched rule '" + rule.getName() + "' of " + rule.getScope(), rule.getName());
    }

    public static UrlCheckResult denied(String reason) {
        return new UrlCheckResult(false, reason, null);
    }

    public boolean isAllowed() {
        return allowed;
    }

    public String getReason() {
        return reason;
    }

    /**
     * @return the name of the rule that allowed the URL, or {@code null} when none did.
     */
    public String getMatchedRule() {
        return matchedRule;
    }

    @Override
    public String toString() {
        return (allowed ? "allowed" : "denied") + ": " + reason;
    }
}
