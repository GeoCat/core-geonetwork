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

import com.google.common.net.InetAddresses;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.utils.Log;

import java.net.IDN;
import java.net.Inet6Address;
import java.net.InetAddress;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.EnumMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

/**
 * Default {@link UrlAllowlistService}.
 *
 * <p>A URL is normalised before it is matched, and two gates are applied above the rules: the
 * scheme allowlist, and internal IP literals. Both sit above rule matching on purpose — a broad
 * or careless rule must not be able to open a path to a loopback service or to a cloud metadata
 * endpoint.</p>
 *
 * <p>Configuration is set by the caller; nothing here reads the database, which is what lets the
 * same instance answer from background threads, from validation and from the shared HTTP client.
 * Rules are compiled when they are set, so matching does no regex compilation.</p>
 *
 * <p>Known limitation: the internal-address gate is name-based. A host name that resolves to an
 * internal address at connect time (DNS rebinding) is not caught here; validating the resolved
 * address at connect time is separate, later work.</p>
 */
public class UrlAllowlistServiceImpl implements UrlAllowlistService {

    /**
     * scheme:// + authority + the rest, used only to punycode an international host.
     */
    private static final Pattern AUTHORITY = Pattern.compile("^([A-Za-z][A-Za-z0-9+.\\-]*://)([^/?#]*)(.*)$");

    private static final Set<String> DEFAULT_SCHEMES =
        Collections.unmodifiableSet(new HashSet<>(Arrays.asList("http", "https")));

    private volatile boolean enabled = false;
    private volatile boolean auditMode = false;
    private volatile boolean allowInternalAddresses = false;
    private volatile Set<String> allowedSchemes = DEFAULT_SCHEMES;
    private volatile List<UrlRule> rules = Collections.emptyList();
    private volatile List<UrlRule> implicitRules = Collections.emptyList();
    private volatile Map<UrlScope, UrlScopeMode> modes = Collections.emptyMap();

    /**
     * What every scope ends up evaluating, worked out whenever the configuration changes rather
     * than on each check.
     */
    private volatile Map<UrlScope, List<UrlRule>> resolvedRules = emptyResolution();

    @Override
    public boolean isAllowed(String url, UrlScope scope) {
        UrlCheckResult result = test(url, scope);
        if (result.isAllowed()) {
            return true;
        }
        if (auditMode) {
            Log.warning(Geonet.SECURITY, String.format(
                "URL allowlist (audit mode): would refuse '%s' for %s - %s", url, scope, result.getReason()));
            return true;
        }
        Log.warning(Geonet.SECURITY, String.format(
            "URL allowlist: refused '%s' for %s - %s", url, scope, result.getReason()));
        return false;
    }

    @Override
    public void assertAllowed(String url, UrlScope scope) {
        if (!isAllowed(url, scope)) {
            throw new UrlNotAllowedException(url, scope, test(url, scope).getReason());
        }
    }

    @Override
    public UrlCheckResult test(String url, UrlScope scope) {
        if (!enabled) {
            return UrlCheckResult.allowed("URL checks are disabled");
        }
        return testRules(url, scope);
    }

    @Override
    public UrlCheckResult testRules(String url, UrlScope scope) {
        if (getMode(scope) == UrlScopeMode.DISABLED) {
            return UrlCheckResult.allowed("URL checks are disabled for " + scope);
        }
        if (url == null || url.trim().isEmpty()) {
            return UrlCheckResult.denied("empty URL");
        }
        if (hasControlCharacter(url)) {
            return UrlCheckResult.denied("URL contains a control or whitespace character");
        }

        String trimmed = url.trim();
        URI uri = parseOrNull(trimmed);
        if (uri == null || (!uri.isOpaque() && uri.getHost() == null)) {
            // java.net.URI reports no host for an international domain name, so retry in punycode
            URI retry = parseOrNull(punycodeAuthority(trimmed));
            if (retry != null && retry.getHost() != null) {
                uri = retry;
            }
        }
        if (uri == null) {
            return UrlCheckResult.denied("malformed URL");
        }
        if (uri.isOpaque() || uri.getScheme() == null) {
            return UrlCheckResult.denied("URL has no scheme and host");
        }

        String scheme = uri.getScheme().toLowerCase(Locale.ROOT);
        if (!allowedSchemes.contains(scheme)) {
            return UrlCheckResult.denied("scheme '" + scheme + "' is not allowed");
        }

        // getHost() drops any userinfo, so https://allowed.org@evil.org/ is matched on evil.org
        if (uri.getHost() == null) {
            return UrlCheckResult.denied("URL has no host");
        }
        String host;
        try {
            host = IDN.toASCII(UrlRule.stripBrackets(uri.getHost().toLowerCase(Locale.ROOT)));
        } catch (IllegalArgumentException e) {
            return UrlCheckResult.denied("host cannot be encoded: " + e.getMessage());
        }

        if (!allowInternalAddresses && isInternalAddress(host)) {
            return UrlCheckResult.denied(
                "host '" + host + "' is an internal address; set allowInternalAddresses to allow it");
        }

        int port = uri.getPort() == -1 ? defaultPort(scheme) : uri.getPort();
        String path = (uri.getPath() == null || uri.getPath().isEmpty()) ? "/" : uri.getPath();

        for (UrlRule rule : getRules(scope)) {
            if (rule.isEnabled() && rule.matches(scheme, host, port, path)) {
                return UrlCheckResult.allowedBy(rule);
            }
        }
        return UrlCheckResult.denied("no allowlist rule matches");
    }

    /**
     * The rules a scope evaluates, in order: the implicit ones first, then whatever its mode
     * resolves to.
     */
    @Override
    public List<UrlRule> getRules(UrlScope scope) {
        return resolvedRules.getOrDefault(scope, Collections.emptyList());
    }

    /**
     * @return the configured mode, or {@link UrlScopeMode#INHERIT}. The global scope has no mode of
     * its own: it is what the others inherit.
     */
    @Override
    public UrlScopeMode getMode(UrlScope scope) {
        if (scope == null || scope == UrlScope.GLOBAL) {
            return UrlScopeMode.INHERIT;
        }
        return modes.getOrDefault(scope, UrlScopeMode.INHERIT);
    }

    private static Map<UrlScope, List<UrlRule>> emptyResolution() {
        Map<UrlScope, List<UrlRule>> resolution = new EnumMap<>(UrlScope.class);
        for (UrlScope scope : UrlScope.values()) {
            resolution.put(scope, Collections.emptyList());
        }
        return Collections.unmodifiableMap(resolution);
    }

    private List<UrlRule> rulesOf(UrlScope scope) {
        List<UrlRule> owned = new ArrayList<>();
        for (UrlRule rule : rules) {
            if (rule.getScope() == scope) {
                owned.add(rule);
            }
        }
        return owned;
    }

    /**
     * Applies the modes once, so a check is a lookup and a match.
     */
    private synchronized void resolve() {
        Map<UrlScope, List<UrlRule>> resolution = new EnumMap<>(UrlScope.class);
        List<UrlRule> global = rulesOf(UrlScope.GLOBAL);
        for (UrlScope scope : UrlScope.values()) {
            List<UrlRule> applicable = new ArrayList<>(implicitRules);
            switch (getMode(scope)) {
                case EXTEND:
                    applicable.addAll(global);
                    applicable.addAll(rulesOf(scope));
                    break;
                case OVERRIDE:
                    applicable.addAll(rulesOf(scope));
                    break;
                case DISABLED:
                    // nothing is evaluated; test() returns before it gets here
                    break;
                case INHERIT:
                default:
                    applicable.addAll(global);
                    break;
            }
            resolution.put(scope, Collections.unmodifiableList(applicable));
        }
        this.resolvedRules = Collections.unmodifiableMap(resolution);
    }

    private static URI parseOrNull(String url) {
        if (url == null) {
            return null;
        }
        try {
            return new URI(url).normalize();
        } catch (URISyntaxException e) {
            return null;
        }
    }

    /**
     * Re-encodes the host of a URL in punycode, leaving userinfo, port and path untouched.
     *
     * @return null when the URL has no parseable authority, or the host cannot be encoded.
     */
    private static String punycodeAuthority(String url) {
        Matcher matcher = AUTHORITY.matcher(url);
        if (!matcher.matches()) {
            return null;
        }
        String authority = matcher.group(2);
        int at = authority.lastIndexOf('@');
        String userinfo = at == -1 ? "" : authority.substring(0, at + 1);
        String hostAndPort = authority.substring(at + 1);
        int colon = hostAndPort.lastIndexOf(':');
        // a colon inside [..] belongs to an IPv6 literal, not to a port
        String host = (colon > -1 && hostAndPort.indexOf(']') < colon)
            ? hostAndPort.substring(0, colon) : hostAndPort;
        String port = hostAndPort.substring(host.length());
        try {
            return matcher.group(1) + userinfo + IDN.toASCII(host) + port + matcher.group(3);
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    private static boolean hasControlCharacter(String url) {
        return url.trim().chars().anyMatch(c -> c < 0x21 || c == 0x7F);
    }

    private static int defaultPort(String scheme) {
        if ("http".equals(scheme)) {
            return 80;
        }
        if ("https".equals(scheme)) {
            return 443;
        }
        return -1;
    }

    /**
     * True when the host is an IP literal in a loopback, link-local, private or multicast range.
     * A host <em>name</em> always returns false here — this gate is about literals that bypass a
     * name-based allowlist, such as 169.254.169.254.
     */
    static boolean isInternalAddress(String host) {
        if (!InetAddresses.isInetAddress(host)) {
            return false;
        }
        return isInternal(InetAddresses.forString(host));
    }

    private static boolean isInternal(InetAddress address) {
        if (address.isAnyLocalAddress() || address.isLoopbackAddress() || address.isLinkLocalAddress()
            || address.isSiteLocalAddress() || address.isMulticastAddress()) {
            return true;
        }
        if (address instanceof Inet6Address) {
            Inet6Address ipv6 = (Inet6Address) address;
            // fc00::/7 unique local addresses, which isSiteLocalAddress() does not cover
            if ((ipv6.getAddress()[0] & 0xFE) == 0xFC) {
                return true;
            }
            if (InetAddresses.hasEmbeddedIPv4ClientAddress(ipv6)) {
                return isInternal(InetAddresses.getEmbeddedIPv4ClientAddress(ipv6));
            }
        }
        return false;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public boolean isEnabled() {
        return enabled;
    }

    /**
     * In audit mode nothing is refused; refusals are logged instead. This is how an operator finds
     * out what a rule set would break before enforcing it.
     */
    public void setAuditMode(boolean auditMode) {
        this.auditMode = auditMode;
    }

    public boolean isAuditMode() {
        return auditMode;
    }

    public void setAllowInternalAddresses(boolean allowInternalAddresses) {
        this.allowInternalAddresses = allowInternalAddresses;
    }

    public boolean isAllowInternalAddresses() {
        return allowInternalAddresses;
    }

    public void setAllowedSchemes(Set<String> allowedSchemes) {
        this.allowedSchemes = (allowedSchemes == null || allowedSchemes.isEmpty())
            ? DEFAULT_SCHEMES
            : Collections.unmodifiableSet(allowedSchemes.stream()
                .map(s -> s.toLowerCase(Locale.ROOT)).collect(Collectors.toSet()));
    }

    /**
     * Replaces the rule set. Patterns are compiled by {@link UrlRule}, so this is also where the
     * compiled-pattern cache is refreshed.
     */
    public void setRules(List<UrlRule> rules) {
        this.rules = rules == null ? Collections.emptyList() : Collections.unmodifiableList(rules);
        resolve();
    }

    /**
     * Rules every scope evaluates whatever its mode, such as the catalogue's own address. A scope
     * on OVERRIDE still has to be able to reach the catalogue itself.
     */
    public void setImplicitRules(List<UrlRule> implicitRules) {
        this.implicitRules = implicitRules == null
            ? Collections.emptyList() : Collections.unmodifiableList(implicitRules);
        resolve();
    }

    public void setModes(Map<UrlScope, UrlScopeMode> modes) {
        this.modes = modes == null || modes.isEmpty()
            ? Collections.emptyMap() : Collections.unmodifiableMap(new EnumMap<>(modes));
        resolve();
    }

    public Map<UrlScope, UrlScopeMode> getModes() {
        return modes;
    }
}
