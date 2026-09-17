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

import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.UrlAllowlistRule;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.kernel.setting.Settings;
import org.fao.geonet.repository.UrlAllowlistRuleRepository;
import org.fao.geonet.utils.Log;
import org.springframework.beans.factory.annotation.Autowired;

import javax.annotation.PostConstruct;
import java.util.ArrayList;
import java.util.List;

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

        List<UrlRule> rules = new ArrayList<>();
        for (UrlAllowlistRule stored : ruleRepository.findAllByOrderByNameAsc()) {
            try {
                rules.add(new UrlRule(stored.getName(), stored.getDescription(),
                    stored.getPattern(), stored.isEnabled()));
            } catch (IllegalArgumentException e) {
                // one unusable pattern must not take the rest of the list with it; dropping the
                // rule is the safe direction, it can only refuse URLs it would have allowed
                Log.error(Geonet.SECURITY, String.format(
                    "URL allowlist: ignoring rule '%s', %s", stored.getName(), e.getMessage()));
            }
        }
        service.setRules(rules);
    }

    @PostConstruct
    public void init() {
        try {
            reload();
        } catch (Exception e) {
            // the catalogue has to start; the feature is off by default, and an administrator can
            // reload it from the administration screen once the cause is fixed
            Log.error(Geonet.SECURITY, "URL allowlist: configuration could not be loaded at start-up, "
                + "checks stay disabled until it is reloaded", e);
        }
    }
}
