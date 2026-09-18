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

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.Setting;
import org.fao.geonet.domain.UrlAllowlistRule;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.kernel.setting.Settings;
import org.fao.geonet.repository.UrlAllowlistRuleRepository;
import org.fao.geonet.utils.Log;
import org.fao.geonet.utils.UrlAllowlistChecks;
import org.springframework.beans.factory.annotation.Autowired;

import javax.annotation.PostConstruct;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;

/**
 * Feeds {@link UrlAllowlistServiceImpl} from the settings and the rule table.
 *
 * <p>The service itself never reads the database — that is what lets it answer from background
 * threads, from validation and from the shared HTTP client. Everything it needs is pushed in from
 * here, at start-up and whenever the configuration is changed.</p>
 */
public class UrlAllowlistConfigLoader {

    @Autowired
    private SettingManager settingManager;

    @Autowired
    private UrlAllowlistRuleRepository ruleRepository;

    @Autowired
    private UrlAllowlistServiceImpl service;


    /**
     * Re-reads the configuration. Called after any change to the settings or the rules.
     */
    public void reload() {
        service.setEnabled(settingManager.getValueAsBool(Settings.SYSTEM_URLALLOWLIST_ENABLED, false));
        service.setAuditMode(settingManager.getValueAsBool(Settings.SYSTEM_URLALLOWLIST_AUDITMODE, false));
        service.setAllowInternalAddresses(
            settingManager.getValueAsBool(Settings.SYSTEM_URLALLOWLIST_ALLOWINTERNALADDRESSES, false));

        service.setModes(readModes());

        List<UrlRule> implicitRules = new ArrayList<>();
        addCatalogueRule(implicitRules);
        service.setImplicitRules(implicitRules);

        List<UrlRule> rules = new ArrayList<>();
        for (UrlAllowlistRule stored : ruleRepository.findAllByOrderByNameAsc()) {
            try {
                rules.add(new UrlRule(stored.getName(), stored.getDescription(),
                    stored.getPattern(), stored.isEnabled(), scopeOf(stored)));
            } catch (IllegalArgumentException e) {
                // one unusable pattern must not take the rest of the list with it; dropping the
                // rule is the safe direction, it can only refuse URLs it would have allowed
                Log.error(Geonet.SECURITY, String.format(
                    "URL allowlist: ignoring rule '%s', %s", stored.getName(), e.getMessage()));
            }
        }
        service.setRules(rules);
    }

    /**
     * A rule stored with a scope this version does not know falls back to the global list rather
     * than being dropped, which can only make it apply more widely, never less.
     */
    private UrlScope scopeOf(UrlAllowlistRule stored) {
        if (stored.getScope() == null || stored.getScope().trim().isEmpty()) {
            return UrlScope.GLOBAL;
        }
        try {
            return UrlScope.valueOf(stored.getScope().trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            Log.warning(Geonet.SECURITY, String.format(
                "URL allowlist: rule '%s' has an unknown scope '%s', treating it as %s",
                stored.getName(), stored.getScope(), UrlScope.GLOBAL));
            return UrlScope.GLOBAL;
        }
    }

    /**
     * The per-feature modes, kept as one JSON setting because only the scopes an administrator has
     * actually changed are worth storing; everything else inherits.
     */
    private Map<UrlScope, UrlScopeMode> readModes() {
        Map<UrlScope, UrlScopeMode> modes = new EnumMap<>(UrlScope.class);
        String value = settingManager.getValue(Settings.SYSTEM_URLALLOWLIST_SCOPEMODES);
        if (value == null || value.trim().isEmpty()) {
            return modes;
        }
        try {
            Map<String, String> stored = new ObjectMapper()
                .readValue(value, new TypeReference<Map<String, String>>() {
                });
            stored.forEach((scope, mode) -> {
                try {
                    modes.put(UrlScope.valueOf(scope.trim().toUpperCase()),
                        UrlScopeMode.valueOf(mode.trim().toUpperCase()));
                } catch (IllegalArgumentException e) {
                    Log.warning(Geonet.SECURITY, String.format(
                        "URL allowlist: ignoring unknown scope or mode '%s: %s'", scope, mode));
                }
            });
        } catch (Exception e) {
            Log.error(Geonet.SECURITY, "URL allowlist: scope modes cannot be read, every feature "
                + "falls back to the global rules", e);
        }
        return modes;
    }

    /**
     * The catalogue is always allowed to reach itself, otherwise enabling the checks breaks the
     * health check and everything else that calls the local instance, and the first thing an
     * administrator does is switch the feature off again.
     *
     * <p>The rule is derived from the base URL rather than stored, so it follows the catalogue when
     * it moves. A base URL on a literal internal address is still subject to the internal address
     * gate, which sits above the rules.</p>
     */
    private void addCatalogueRule(List<UrlRule> rules) {
        String baseUrl = settingManager.getBaseURL();
        if (baseUrl == null || baseUrl.trim().isEmpty()) {
            return;
        }
        try {
            URI uri = new URI(baseUrl.trim());
            if (uri.getScheme() == null || uri.getHost() == null) {
                return;
            }
            String pattern = uri.getScheme() + "://" + uri.getHost()
                + (uri.getPort() == -1 ? "" : ":" + uri.getPort());
            rules.add(new UrlRule("catalogue", "This catalogue, always allowed", pattern, true));
        } catch (URISyntaxException e) {
            Log.warning(Geonet.SECURITY,
                "URL allowlist: base URL '" + baseUrl + "' cannot be parsed, the catalogue itself "
                    + "is not implicitly allowed");
        }
    }

    /**
     * Adapts the allowlist to the seam the shared HTTP client holds, which cannot see this module.
     */
    private void check(String url, String scope) {
        UrlScope resolved;
        try {
            resolved = UrlScope.valueOf(scope);
        } catch (IllegalArgumentException e) {
            resolved = UrlScope.GLOBAL;
        }
        service.assertAllowed(url, UrlScopeContext.resolve(resolved));
    }

    /**
     * Carries over the thesaurus allowlist of 4.4.x, which was a single setting holding wildcard
     * patterns.
     *
     * <p>The patterns become rules of the thesaurus feature, that feature is held to those rules
     * alone, and the checks are switched on: an upgrade must not quietly drop a protection the
     * catalogue already had. The old setting is emptied once it has been read, so this runs once.
     * </p>
     *
     * <p>The setting is found by name rather than by a constant, because the name differed between
     * the versions that shipped it.</p>
     */
    void migrateLegacyAllowlist() {
        Setting legacy = null;
        for (Setting setting : settingManager.getAll()) {
            String name = setting.getName() == null ? "" : setting.getName().toLowerCase();
            if (name.contains("allowlist") && !name.startsWith("system/urlallowlist")
                && setting.getValue() != null && !setting.getValue().trim().isEmpty()) {
                legacy = setting;
                break;
            }
        }
        if (legacy == null) {
            return;
        }

        int created = 0;
        for (String pattern : legacy.getValue().split("[\\s,;|]+")) {
            if (pattern.trim().isEmpty()) {
                continue;
            }
            try {
                // compiled here so that an unusable pattern is reported rather than stored
                new UrlRule("thesaurus", null, pattern.trim(), true, UrlScope.THESAURUS);
                ruleRepository.save(new UrlAllowlistRule()
                    .setName("thesaurus-" + (created + 1))
                    .setDescription("Migrated from " + legacy.getName())
                    .setPattern(pattern.trim())
                    .setScope(UrlScope.THESAURUS.name())
                    .setEnabled(true));
                created++;
            } catch (IllegalArgumentException e) {
                Log.error(Geonet.SECURITY, String.format(
                    "URL allowlist: pattern '%s' of %s cannot be migrated, %s",
                    pattern, legacy.getName(), e.getMessage()));
            }
        }

        if (created > 0) {
            // 4.4.x restricted thesaurus downloads and nothing else, so everything else is left
            // unrestricted: a rule that allows any host, which an administrator can narrow, and
            // the link checker exempted because it follows whatever records point at, over ftp as
            // well as http.
            ruleRepository.save(new UrlAllowlistRule()
                .setName("everything")
                .setDescription("Migrated: the catalogue reached any host except for thesaurus "
                    + "downloads. Narrow or remove this rule to restrict it.")
                .setPattern("*")
                .setScope(UrlScope.GLOBAL.name())
                .setEnabled(true));
            settingManager.setValue(Settings.SYSTEM_URLALLOWLIST_SCOPEMODES,
                "{\"" + UrlScope.THESAURUS.name() + "\":\"" + UrlScopeMode.OVERRIDE.name() + "\","
                    + "\"" + UrlScope.ONLINE_RESOURCE.name() + "\":\"" + UrlScopeMode.DISABLED.name() + "\"}");
            settingManager.setValue(Settings.SYSTEM_URLALLOWLIST_ENABLED, true);
            Log.warning(Geonet.SECURITY, String.format(
                "URL allowlist: %d rule(s) migrated from %s. The thesaurus feature is held to "
                    + "those rules, and every other feature keeps reaching any host through the "
                    + "rule named 'everything', which reproduces what this catalogue did before. "
                    + "Narrow that rule to restrict the rest of the catalogue.",
                created, legacy.getName()));
        }
        settingManager.setValue(legacy.getName(), "");
    }

    @PostConstruct
    public void init() {
        // installed before the configuration is read, so a failure below cannot leave the
        // catalogue unchecked while the settings say otherwise
        UrlAllowlistChecks.set(this::check);
        try {
            migrateLegacyAllowlist();
            reload();
        } catch (Exception e) {
            // the catalogue has to start; the feature is off by default, and an administrator can
            // reload it from the administration screen once the cause is fixed
            Log.error(Geonet.SECURITY, "URL allowlist: configuration could not be loaded at start-up, "
                + "checks stay disabled until it is reloaded", e);
        }
    }
}
