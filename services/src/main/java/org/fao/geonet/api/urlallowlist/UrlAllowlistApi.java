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

package org.fao.geonet.api.urlallowlist;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.apache.commons.lang.StringUtils;
import org.fao.geonet.api.ApiParams;
import org.fao.geonet.api.exception.ResourceNotFoundException;
import org.fao.geonet.domain.DoiServer;
import org.fao.geonet.domain.HarvesterSetting;
import org.fao.geonet.domain.MapServer;
import org.fao.geonet.domain.UrlAllowlistRule;
import org.fao.geonet.kernel.security.url.UrlAllowlistConfigLoader;
import org.fao.geonet.kernel.security.url.UrlAllowlistService;
import org.fao.geonet.kernel.security.url.UrlCheckResult;
import org.fao.geonet.kernel.security.url.UrlRule;
import org.fao.geonet.kernel.security.url.UrlScope;
import org.fao.geonet.kernel.security.url.UrlScopeMode;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.kernel.setting.Settings;
import org.fao.geonet.repository.DoiServerRepository;
import org.fao.geonet.repository.HarvesterSettingRepository;
import org.fao.geonet.repository.MapServerRepository;
import org.fao.geonet.repository.UrlAllowlistRuleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Administration of the URL allowlist: the rules, and a way to try a URL against them.
 */
@RequestMapping(value = {
    "/{portal}/api/urlallowlist"
})
@Tag(name = "urlallowlist",
    description = "URL allowlist operations")
@Controller("urlallowlist")
public class UrlAllowlistApi {

    private static final String MSG_RULE_NOT_FOUND = "URL allowlist rule with id '%d' not found.";

    @Autowired
    UrlAllowlistRuleRepository ruleRepository;

    @Autowired
    UrlAllowlistService urlAllowlistService;

    @Autowired
    UrlAllowlistConfigLoader configLoader;

    @Autowired
    SettingManager settingManager;

    @Autowired
    HarvesterSettingRepository harvesterSettingRepository;

    @Autowired
    MapServerRepository mapServerRepository;

    @Autowired
    DoiServerRepository doiServerRepository;

    @io.swagger.v3.oas.annotations.Operation(
        summary = "Get the URL allowlist rules",
        description = "Rules describe which URLs the catalogue is allowed to use. They only take "
            + "effect once URL checks are enabled in the system settings.")
    @RequestMapping(
        value = "/rules",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    @ResponseStatus(HttpStatus.OK)
    @PreAuthorize("hasAuthority('Administrator')")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "List of rules."),
        @ApiResponse(responseCode = "403", description = ApiParams.API_RESPONSE_NOT_ALLOWED_ONLY_ADMIN)
    })
    public List<UrlAllowlistRule> getRules() {
        return ruleRepository.findAllByOrderByNameAsc();
    }

    @io.swagger.v3.oas.annotations.Operation(summary = "Add a URL allowlist rule")
    @RequestMapping(
        value = "/rules",
        method = RequestMethod.POST,
        consumes = MediaType.APPLICATION_JSON_VALUE,
        produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAuthority('Administrator')")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Rule created."),
        @ApiResponse(responseCode = "400", description = "Invalid rule."),
        @ApiResponse(responseCode = "403", description = ApiParams.API_RESPONSE_NOT_ALLOWED_ONLY_ADMIN)
    })
    public UrlAllowlistRule addRule(@RequestBody UrlAllowlistRule rule) {
        rule.setId(0);
        return save(rule);
    }

    @io.swagger.v3.oas.annotations.Operation(summary = "Update a URL allowlist rule")
    @RequestMapping(
        value = "/rules/{id}",
        method = RequestMethod.PUT,
        consumes = MediaType.APPLICATION_JSON_VALUE,
        produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    @ResponseStatus(HttpStatus.OK)
    @PreAuthorize("hasAuthority('Administrator')")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Rule updated."),
        @ApiResponse(responseCode = "400", description = "Invalid rule."),
        @ApiResponse(responseCode = "404", description = "Rule not found."),
        @ApiResponse(responseCode = "403", description = ApiParams.API_RESPONSE_NOT_ALLOWED_ONLY_ADMIN)
    })
    public UrlAllowlistRule updateRule(
        @Parameter(description = "Rule identifier", required = true) @PathVariable int id,
        @RequestBody UrlAllowlistRule rule) throws ResourceNotFoundException {
        requireExisting(id);
        rule.setId(id);
        return save(rule);
    }

    @io.swagger.v3.oas.annotations.Operation(summary = "Remove a URL allowlist rule")
    @RequestMapping(
        value = "/rules/{id}",
        method = RequestMethod.DELETE)
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasAuthority('Administrator')")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Rule removed."),
        @ApiResponse(responseCode = "404", description = "Rule not found."),
        @ApiResponse(responseCode = "403", description = ApiParams.API_RESPONSE_NOT_ALLOWED_ONLY_ADMIN)
    })
    public void deleteRule(
        @Parameter(description = "Rule identifier", required = true) @PathVariable int id)
        throws ResourceNotFoundException {
        ruleRepository.delete(requireExisting(id));
        configLoader.reload();
    }

    @io.swagger.v3.oas.annotations.Operation(
        summary = "Get the per-feature modes",
        description = "Every feature either inherits the global rules, extends them with its own, "
            + "overrides them, or is not checked at all. A feature nobody has configured inherits.")
    @RequestMapping(
        value = "/scopes",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    @ResponseStatus(HttpStatus.OK)
    @PreAuthorize("hasAuthority('Administrator')")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "The modes, and the modes to choose from."),
        @ApiResponse(responseCode = "403", description = ApiParams.API_RESPONSE_NOT_ALLOWED_ONLY_ADMIN)
    })
    public Map<String, Object> getScopes() {
        List<String> modes = new ArrayList<>();
        for (UrlScopeMode mode : UrlScopeMode.values()) {
            modes.add(mode.name());
        }
        Map<String, String> scopes = new LinkedHashMap<>();
        for (UrlScope scope : UrlScope.values()) {
            if (scope != UrlScope.GLOBAL) {
                scopes.put(scope.name(), urlAllowlistService.getMode(scope).name());
            }
        }
        Map<String, Object> response = new LinkedHashMap<>();
        response.put("modes", modes);
        response.put("scopes", scopes);
        return response;
    }

    @io.swagger.v3.oas.annotations.Operation(
        summary = "Set the per-feature modes",
        description = "Only the features given are changed; the rest keep what they had.")
    @RequestMapping(
        value = "/scopes",
        method = RequestMethod.PUT,
        consumes = MediaType.APPLICATION_JSON_VALUE)
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasAuthority('Administrator')")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Modes saved."),
        @ApiResponse(responseCode = "400", description = "Unknown feature or mode."),
        @ApiResponse(responseCode = "403", description = ApiParams.API_RESPONSE_NOT_ALLOWED_ONLY_ADMIN)
    })
    public void setScopes(@RequestBody Map<String, String> modes) throws Exception {
        Map<String, String> toStore = new LinkedHashMap<>();
        for (Map.Entry<String, String> entry : modes.entrySet()) {
            UrlScope scope = toScope(entry.getKey());
            if (scope == UrlScope.GLOBAL) {
                throw new IllegalArgumentException(
                    "The global scope has no mode of its own; it is what the others inherit");
            }
            UrlScopeMode mode;
            try {
                mode = UrlScopeMode.valueOf(entry.getValue().toUpperCase());
            } catch (IllegalArgumentException e) {
                throw new IllegalArgumentException("Unknown mode '" + entry.getValue() + "'");
            }
            // only what differs from the default is worth storing
            if (mode != UrlScopeMode.INHERIT) {
                toStore.put(scope.name(), mode.name());
            }
        }
        settingManager.setValue(Settings.SYSTEM_URLALLOWLIST_SCOPEMODES,
            new ObjectMapper().writeValueAsString(toStore));
        configLoader.reload();
    }

    @io.swagger.v3.oas.annotations.Operation(
        summary = "Get the rules a feature actually evaluates",
        description = "The result of applying the feature's mode: what a check for that feature "
            + "is matched against, including the rules that apply whatever the mode.")
    @RequestMapping(
        value = "/effectiverules",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    @ResponseStatus(HttpStatus.OK)
    @PreAuthorize("hasAuthority('Administrator')")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "The rules in evaluation order."),
        @ApiResponse(responseCode = "403", description = ApiParams.API_RESPONSE_NOT_ALLOWED_ONLY_ADMIN)
    })
    public List<Map<String, Object>> getEffectiveRules(
        @Parameter(description = "The feature") @RequestParam(required = false, defaultValue = "GLOBAL")
            String scope) {
        List<Map<String, Object>> effective = new ArrayList<>();
        for (UrlRule rule : urlAllowlistService.getRules(toScope(scope))) {
            Map<String, Object> described = new LinkedHashMap<>();
            described.put("name", rule.getName());
            described.put("pattern", rule.getPattern());
            described.put("scope", rule.getScope().name());
            described.put("enabled", rule.isEnabled());
            effective.add(described);
        }
        return effective;
    }

    @io.swagger.v3.oas.annotations.Operation(
        summary = "Report the configured addresses the rules would refuse",
        description = "Walks the addresses already configured in this catalogue — harvesters, map "
            + "servers and DOI servers — and reports those the current rules would refuse. The "
            + "answer does not depend on whether the checks are switched on, so it can be used "
            + "before enabling them.")
    @RequestMapping(
        value = "/report",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    @ResponseStatus(HttpStatus.OK)
    @PreAuthorize("hasAuthority('Administrator')")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "The addresses that would be refused."),
        @ApiResponse(responseCode = "403", description = ApiParams.API_RESPONSE_NOT_ALLOWED_ONLY_ADMIN)
    })
    public List<Map<String, Object>> getReport() {
        List<Map<String, Object>> refused = new ArrayList<>();

        for (HarvesterSetting site : harvesterSettingRepository.findAllByName("site")) {
            String name = firstValue(site.getId(), "name");
            String url = firstValue(site.getId(), "url");
            report(refused, "harvester", name, url, UrlScope.HARVESTER);
        }
        for (MapServer mapServer : mapServerRepository.findAll()) {
            for (String url : new String[]{mapServer.getConfigurl(), mapServer.getWmsurl(),
                mapServer.getWfsurl(), mapServer.getWcsurl(), mapServer.getStylerurl()}) {
                report(refused, "mapserver", mapServer.getName(), url, UrlScope.MAPSERVER);
            }
        }
        for (DoiServer doiServer : doiServerRepository.findAll()) {
            report(refused, "doiserver", doiServer.getName(), doiServer.getUrl(), UrlScope.DOI);
        }
        return refused;
    }

    private String firstValue(int parentId, String name) {
        List<HarvesterSetting> children = harvesterSettingRepository.findChildrenByName(parentId, name);
        return children.isEmpty() ? null : children.get(0).getValue();
    }

    private void report(List<Map<String, Object>> refused, String source, String name, String url,
                        UrlScope scope) {
        if (url == null || url.trim().isEmpty()) {
            return;
        }
        UrlCheckResult result = urlAllowlistService.testRules(url.trim(), scope);
        if (!result.isAllowed()) {
            Map<String, Object> entry = new LinkedHashMap<>();
            entry.put("source", source);
            entry.put("name", name);
            entry.put("url", url.trim());
            entry.put("scope", scope.name());
            entry.put("reason", result.getReason());
            refused.add(entry);
        }
    }

    @io.swagger.v3.oas.annotations.Operation(
        summary = "Check a URL against the allowlist",
        description = "Reports the real verdict, with the rule that matched or the reason for the "
            + "refusal. Audit mode does not soften what is reported here.")
    @RequestMapping(
        value = "/test",
        method = RequestMethod.GET,
        produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    @ResponseStatus(HttpStatus.OK)
    @PreAuthorize("hasAuthority('Administrator')")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "The result of the check."),
        @ApiResponse(responseCode = "403", description = ApiParams.API_RESPONSE_NOT_ALLOWED_ONLY_ADMIN)
    })
    public UrlCheckResult testUrl(
        @Parameter(description = "The URL to check", required = true) @RequestParam String url,
        @Parameter(description = "The feature the URL would be used for")
        @RequestParam(required = false, defaultValue = "GLOBAL") String scope) {
        return urlAllowlistService.test(url, toScope(scope));
    }

    private UrlAllowlistRule save(UrlAllowlistRule rule) {
        if (StringUtils.isBlank(rule.getName())) {
            throw new IllegalArgumentException("A URL allowlist rule needs a name");
        }
        if (StringUtils.isBlank(rule.getScope())) {
            rule.setScope(UrlAllowlistRule.SCOPE_GLOBAL);
        }
        toScope(rule.getScope());
        // compiles the pattern, so an unusable one is refused here rather than ignored at load
        new UrlRule(rule.getName(), rule.getDescription(), rule.getPattern(), rule.isEnabled());

        UrlAllowlistRule saved = ruleRepository.save(rule);
        configLoader.reload();
        return saved;
    }

    private UrlAllowlistRule requireExisting(int id) throws ResourceNotFoundException {
        return ruleRepository.findById(id).orElseThrow(
            () -> new ResourceNotFoundException(String.format(MSG_RULE_NOT_FOUND, id)));
    }

    private static UrlScope toScope(String scope) {
        try {
            return UrlScope.valueOf(scope.toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Unknown scope '" + scope + "'");
        }
    }
}
