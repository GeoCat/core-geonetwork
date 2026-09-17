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

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * One allowlist entry, compiled once at construction.
 *
 * <p>Pattern syntax is <code>[scheme://]host[:port][/path-prefix]</code> where <code>*</code>
 * matches any sequence of characters:</p>
 *
 * <ul>
 *   <li><code>https://registry.example.org</code> — that host over https, any port, any path</li>
 *   <li><code>https://*.example.org/thesauri</code> — any sub-domain, paths under /thesauri</li>
 *   <li><code>*.example.org</code> — any sub-domain over any allowed scheme</li>
 * </ul>
 *
 * <p>The host pattern is matched against the <em>whole</em> host, which is what makes
 * <code>*.example.org</code> safe: it matches <code>a.example.org</code> and
 * <code>a.b.example.org</code>, but neither <code>evil-example.org</code> (no dot) nor
 * <code>evil.org/.example.org</code> (the path is not the host). It does not match
 * <code>example.org</code> itself — add a second rule when the apex is needed.</p>
 *
 * <p>Note that <code>*</code> is "any sequence of characters", so a careless
 * <code>*example.org</code> also matches <code>evilexample.org</code>. Prefer the
 * <code>*.</code> form.</p>
 *
 * <p>An omitted scheme or port means "any" (schemes are still restricted by the service's own
 * scheme allowlist). An omitted path means "any path"; a path matches on segment boundaries, so
 * <code>/thesauri</code> allows <code>/thesauri</code> and <code>/thesauri/rdf</code> but not
 * <code>/thesauri-private</code>.</p>
 *
 * <p>This is a plain value object. Persistence of rules is added separately; nothing here depends
 * on how they are stored.</p>
 */
public class UrlRule {

    /**
     * [scheme://]host[:port][/path] — the host group also accepts a bracketed IPv6 literal.
     */
    private static final Pattern SYNTAX = Pattern.compile(
        "^(?:([A-Za-z0-9*+.-]+)://)?(\\[[0-9A-Fa-f:.*]+\\]|[^/:]+)(?::(\\d+|\\*))?(/.*)?$");

    private final String name;
    private final String description;
    private final String pattern;
    private final boolean enabled;
    private final UrlScope scope;

    private final String scheme;
    private final Pattern host;
    private final Integer port;
    private final Pattern path;

    public UrlRule(String name, String pattern) {
        this(name, null, pattern, true, UrlScope.GLOBAL);
    }

    public UrlRule(String name, String description, String pattern, boolean enabled) {
        this(name, description, pattern, enabled, UrlScope.GLOBAL);
    }

    public UrlRule(String name, String description, String pattern, boolean enabled, UrlScope scope) {
        this.name = name;
        this.description = description;
        this.pattern = pattern;
        this.enabled = enabled;
        this.scope = scope == null ? UrlScope.GLOBAL : scope;

        Matcher matcher = SYNTAX.matcher(pattern == null ? "" : pattern.trim());
        if (!matcher.matches()) {
            throw new IllegalArgumentException(
                "Invalid URL allowlist pattern '" + pattern + "'. Expected [scheme://]host[:port][/path]");
        }
        String schemePart = matcher.group(1);
        this.scheme = (schemePart == null || "*".equals(schemePart))
            ? null : schemePart.toLowerCase();
        this.host = Pattern.compile(toRegex(stripBrackets(matcher.group(2).toLowerCase())));
        String portPart = matcher.group(3);
        this.port = (portPart == null || "*".equals(portPart)) ? null : Integer.valueOf(portPart);
        this.path = toPathPattern(matcher.group(4));
    }

    /**
     * Quote everything but <code>*</code>, which becomes "any sequence".
     */
    private static String toRegex(String wildcardPattern) {
        StringBuilder regex = new StringBuilder();
        String[] literals = wildcardPattern.split("\\*", -1);
        for (int i = 0; i < literals.length; i++) {
            if (i > 0) {
                regex.append(".*");
            }
            if (!literals[i].isEmpty()) {
                regex.append(Pattern.quote(literals[i]));
            }
        }
        return regex.toString();
    }

    /**
     * A path prefix that has to end on a segment boundary, so /thesauri does not allow
     * /thesauri-private. A pattern already ending in / or * is used as-is.
     */
    private static Pattern toPathPattern(String pathPart) {
        if (pathPart == null || "/".equals(pathPart)) {
            return null;
        }
        String regex = toRegex(pathPart);
        if (pathPart.endsWith("/") || pathPart.endsWith("*")) {
            return Pattern.compile(regex + ".*");
        }
        return Pattern.compile(regex + "(/.*)?");
    }

    static String stripBrackets(String host) {
        if (host.startsWith("[") && host.endsWith("]")) {
            return host.substring(1, host.length() - 1);
        }
        return host;
    }

    /**
     * @param scheme lower-case scheme
     * @param host   lower-case, punycoded, bracket-free host
     * @param port   the effective port, never -1
     * @param path   the normalised path, never empty
     */
    public boolean matches(String scheme, String host, int port, String path) {
        if (this.scheme != null && !this.scheme.equals(scheme)) {
            return false;
        }
        if (this.port != null && this.port != port) {
            return false;
        }
        if (!this.host.matcher(host).matches()) {
            return false;
        }
        return this.path == null || this.path.matcher(path).matches();
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public String getPattern() {
        return pattern;
    }

    public boolean isEnabled() {
        return enabled;
    }

    /**
     * The feature this rule was written for. Which scopes actually see it depends on their mode.
     */
    public UrlScope getScope() {
        return scope;
    }

    @Override
    public String toString() {
        return name + " (" + pattern + ", " + scope + ")";
    }
}
