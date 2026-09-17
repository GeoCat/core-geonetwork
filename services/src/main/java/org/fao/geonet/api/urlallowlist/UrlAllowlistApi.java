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

import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.apache.commons.lang.StringUtils;
import org.fao.geonet.api.ApiParams;
import org.fao.geonet.api.exception.ResourceNotFoundException;
import org.fao.geonet.domain.UrlAllowlistRule;
import org.fao.geonet.kernel.security.url.UrlAllowlistConfigLoader;
import org.fao.geonet.kernel.security.url.UrlAllowlistService;
import org.fao.geonet.kernel.security.url.UrlCheckResult;
import org.fao.geonet.kernel.security.url.UrlRule;
import org.fao.geonet.kernel.security.url.UrlScope;
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

import java.util.List;

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
