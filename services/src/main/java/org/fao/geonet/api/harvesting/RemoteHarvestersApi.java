/*
 * Copyright (C) 2001-2016 Food and Agriculture Organization of the
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

package org.fao.geonet.api.harvesting;

import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.apache.commons.lang.StringUtils;
import org.fao.geonet.api.ApiParams;
import org.fao.geonet.client.RemoteHarvesterApiClient;
import org.fao.geonet.kernel.setting.SettingManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;


@RequestMapping(value = {
    "/{portal}/api/remoteharvesters"
})
@Tag(name = "remoteharvesters",
    description = "Remote harvester operations")
@Controller("remoteharvesters")
public class RemoteHarvestersApi {
    @Autowired
    SettingManager settingManager;

    @io.swagger.v3.oas.annotations.Operation(
        summary = "Assign harvester records to a new source",
        description = ""
//        authorizations = {
//            @Authorization(value = "basicAuth")
//        })
    )
    @RequestMapping(
        value = "/progress/{processId}",
        produces = MediaType.APPLICATION_JSON_VALUE,
        method = RequestMethod.GET
    )
    @PreAuthorize("hasAuthority('UserAdmin')")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Harvester progress status"),
        @ApiResponse(responseCode = "404", description = ApiParams.API_RESPONSE_RESOURCE_NOT_FOUND),
        @ApiResponse(responseCode = "403", description = ApiParams.API_RESPONSE_NOT_ALLOWED_ONLY_USER_ADMIN)
    })
    @ResponseBody
    public HttpEntity<String> progress(
        @Parameter(
            description = "The harvester process identifier"
        )
        @PathVariable
            String processId
    ) throws Exception {
        String url = settingManager.getValue(RemoteHarvesterApiClient.SETTING_REMOTE_HARVESTER_API);
        if (StringUtils.isEmpty(url)) {
            throw new Exception("Remote harvester API endpoint is not configured. Configure it in the Settings page.");
        }

        RemoteHarvesterApiClient client = new RemoteHarvesterApiClient(url);
        String harvesterProcessStatus = client.retrieveProgress(processId);

        return new HttpEntity<>(harvesterProcessStatus);
    }
}
