/*
 * Copyright (C) 2026 Food and Agriculture Organization of the
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
package org.fao.geonet.kernel.security.keycloak;

import org.fao.geonet.domain.*;
import org.fao.geonet.repository.GroupRepository;
import org.fao.geonet.repository.LanguageRepository;
import org.fao.geonet.repository.UserGroupRepository;
import org.fao.geonet.repository.UserRepository;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.keycloak.adapters.AdapterDeploymentContext;
import org.keycloak.adapters.KeycloakDeployment;
import org.keycloak.representations.AccessToken;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnitRunner;

import java.lang.reflect.Method;
import java.util.*;

import static org.junit.Assert.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@RunWith(MockitoJUnitRunner.class)
public class KeycloakUserUtilsTest {

    private static final String RESOURCE_NAME = "gn-client";
    private static final String SEPARATOR = ":";

    @Mock
    private KeycloakConfiguration keycloakConfiguration;

    @Mock
    private AdapterDeploymentContext adapterDeploymentContext;

    @Mock
    private UserRepository userRepository;

    @Mock
    private UserGroupRepository userGroupRepository;

    @Mock
    private GroupRepository groupRepository;

    @Mock
    private LanguageRepository langRepository;

    @InjectMocks
    private KeycloakUserUtils keycloakUserUtils;

    private KeycloakDeployment keycloakDeployment;

    @Before
    public void setUp() {
        keycloakDeployment = mock(KeycloakDeployment.class);
        when(keycloakDeployment.getResourceName()).thenReturn(RESOURCE_NAME);
        when(adapterDeploymentContext.resolveDeployment(null)).thenReturn(keycloakDeployment);
        when(keycloakConfiguration.getRoleGroupSeparator()).thenReturn(SEPARATOR);
    }

    private AccessToken createAccessTokenWithRoles(String... roles) {
        AccessToken accessToken = mock(AccessToken.class);
        AccessToken.Access access = mock(AccessToken.Access.class);
        when(access.getRoles()).thenReturn(new HashSet<>(Arrays.asList(roles)));
        when(accessToken.getResourceAccess(RESOURCE_NAME)).thenReturn(access);
        return accessToken;
    }

    private List<String> invokeGetSystemGroups(AccessToken accessToken) throws Exception {
        Method method = KeycloakUserUtils.class.getDeclaredMethod("getSystemGroups", AccessToken.class);
        method.setAccessible(true);
        @SuppressWarnings("unchecked")
        List<String> result = (List<String>) method.invoke(keycloakUserUtils, accessToken);
        return result;
    }

    private Map<Profile, List<String>> invokeGetProfileGroups(AccessToken accessToken) throws Exception {
        Method method = KeycloakUserUtils.class.getDeclaredMethod("getProfileGroups", AccessToken.class);
        method.setAccessible(true);
        @SuppressWarnings("unchecked")
        Map<Profile, List<String>> result = (Map<Profile, List<String>>) method.invoke(keycloakUserUtils, accessToken);
        return result;
    }

    @SuppressWarnings("unchecked")
    private void invokeUpdateGroups(List<String> systemGroups, Map<Profile, List<String>> profileGroups, User user) throws Exception {
        Method method = KeycloakUserUtils.class.getDeclaredMethod("updateGroups", List.class, Map.class, User.class);
        method.setAccessible(true);
        method.invoke(keycloakUserUtils, systemGroups, profileGroups, user);
    }

    @Test
    public void getSystemGroups_withValidSystemGroups_returnsSystemGroups() throws Exception {
        AccessToken accessToken = createAccessTokenWithRoles(
            "externalPublicationRequester", "GroupB:Editor", "Administrator");

        List<String> systemGroups = invokeGetSystemGroups(accessToken);

        assertFalse(systemGroups.contains("GroupB:Editor"));
        assertFalse(systemGroups.contains("Administrator"));
        assertEquals(1, systemGroups.size());
        assertTrue(systemGroups.contains("externalPublicationRequester"));
    }

    @Test
    public void getSystemGroups_withAllProfilesOrGroupProfiles_returnsEmpty() throws Exception {
        AccessToken accessToken = createAccessTokenWithRoles(
            "GroupB:Editor", "Administrator", "Reviewer");

        List<String> systemGroups = invokeGetSystemGroups(accessToken);

        assertTrue(systemGroups.isEmpty());
    }

    @Test
    public void getSystemGroups_withNoResourceAccess_returnsEmpty() throws Exception {
        AccessToken accessToken = mock(AccessToken.class);
        when(accessToken.getResourceAccess(RESOURCE_NAME)).thenReturn(null);

        List<String> systemGroups = invokeGetSystemGroups(accessToken);

        assertTrue(systemGroups.isEmpty());
    }

    @Test
    public void getSystemGroups_withMultipleSystemGroups_returnsAll() throws Exception {
        AccessToken accessToken = createAccessTokenWithRoles(
            "systemGroupA", "systemGroupB", "Editor", "GroupC:Reviewer");

        List<String> systemGroups = invokeGetSystemGroups(accessToken);

        assertEquals(2, systemGroups.size());
        assertTrue(systemGroups.contains("systemGroupA"));
        assertTrue(systemGroups.contains("systemGroupB"));
    }

    @Test
    public void updateGroups_withSystemGroups_createsSystemPrivilegeGroups() throws Exception {
        User user = new User();
        user.setId(1);
        user.setUsername("testuser");

        Group sysGroup = new Group();
        sysGroup.setId(10);
        sysGroup.setName("externalPublicationRequester");

        when(groupRepository.findByName("externalPublicationRequester")).thenReturn(sysGroup);

        List<String> systemGroups = Arrays.asList("externalPublicationRequester");
        Map<Profile, List<String>> profileGroups = new HashMap<>();

        invokeUpdateGroups(systemGroups, profileGroups, user);

        @SuppressWarnings("unchecked")
        ArgumentCaptor<Set<UserGroup>> captor = ArgumentCaptor.forClass(Set.class);
        verify(userGroupRepository).updateUserGroups(eq(1), captor.capture());

        Set<UserGroup> savedGroups = captor.getValue();
        assertEquals(1, savedGroups.size());

        UserGroup ug = savedGroups.iterator().next();
        assertEquals(Profile.RegisteredUser, ug.getProfile());
        assertEquals(sysGroup, ug.getGroup());
    }

    @Test
    public void updateGroups_withMixedSystemAndProfileGroups_createsBoth() throws Exception {
        User user = new User();
        user.setId(2);
        user.setUsername("testuser2");

        Group sysGroup = new Group();
        sysGroup.setId(10);
        sysGroup.setName("systemGroup1");

        Group profileGroup = new Group();
        profileGroup.setId(20);
        profileGroup.setName("GroupA");

        when(groupRepository.findByName("systemGroup1")).thenReturn(sysGroup);
        when(groupRepository.findByName("GroupA")).thenReturn(profileGroup);

        List<String> systemGroups = Arrays.asList("systemGroup1");
        Map<Profile, List<String>> profileGroups = new HashMap<>();
        profileGroups.put(Profile.Editor, Arrays.asList("GroupA"));

        invokeUpdateGroups(systemGroups, profileGroups, user);

        @SuppressWarnings("unchecked")
        ArgumentCaptor<Set<UserGroup>> captor = ArgumentCaptor.forClass(Set.class);
        verify(userGroupRepository).updateUserGroups(eq(2), captor.capture());

        Set<UserGroup> savedGroups = captor.getValue();
        assertEquals(2, savedGroups.size());

        boolean hasSystemGroup = false;
        boolean hasProfileGroup = false;
        for (UserGroup ug : savedGroups) {
            if (ug.getGroup().equals(sysGroup) && ug.getProfile().equals(Profile.RegisteredUser)) {
                hasSystemGroup = true;
            }
            if (ug.getGroup().equals(profileGroup) && ug.getProfile().equals(Profile.Editor)) {
                hasProfileGroup = true;
            }
        }
        assertTrue("Should contain system group with RegisteredUser profile", hasSystemGroup);
        assertTrue("Should contain profile group with Editor profile", hasProfileGroup);
    }
}
