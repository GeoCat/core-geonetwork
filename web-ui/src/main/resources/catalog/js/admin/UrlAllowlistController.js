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

(function () {
  goog.provide("gn_urlallowlist_controller");

  var module = angular.module("gn_urlallowlist_controller", []);

  /**
   * GnUrlAllowlistController manages the rules describing which URLs the
   * catalogue is allowed to use, and lets an administrator try a URL against
   * them before enabling the checks.
   */
  module.controller("GnUrlAllowlistController", [
    "$scope",
    "$http",
    "$rootScope",
    "$translate",
    function ($scope, $http, $rootScope, $translate) {
      $scope.rules = [];
      $scope.ruleSelected = null;
      $scope.isUpdate = false;
      $scope.testUrl = "";
      $scope.testResult = null;

      function loadRules() {
        $http.get("../api/urlallowlist/rules").then(function (response) {
          $scope.rules = response.data;
        });
      }

      function report(key, response, isError) {
        $rootScope.$broadcast("StatusUpdated", {
          title: isError ? $translate.instant(key) : undefined,
          msg: isError ? undefined : $translate.instant(key),
          error: isError ? response.data : undefined,
          timeout: isError ? 0 : 2,
          type: isError ? "danger" : "success"
        });
      }

      $scope.selectRule = function (rule) {
        $scope.ruleSelected = angular.copy(rule);
        $scope.isUpdate = true;
        $scope.testResult = null;
      };

      $scope.addRule = function () {
        $scope.ruleSelected = {
          name: "",
          description: "",
          pattern: "",
          scope: "GLOBAL",
          enabled: true
        };
        $scope.isUpdate = false;
        $scope.testResult = null;
      };

      $scope.saveRule = function () {
        var request = $scope.isUpdate
          ? $http.put(
              "../api/urlallowlist/rules/" + $scope.ruleSelected.id,
              $scope.ruleSelected
            )
          : $http.post("../api/urlallowlist/rules", $scope.ruleSelected);

        request.then(
          function () {
            loadRules();
            report("urlAllowlistRuleUpdated");
          },
          function (response) {
            report("urlAllowlistRuleUpdateError", response, true);
          }
        );
      };

      $scope.deleteRule = function () {
        $http.delete("../api/urlallowlist/rules/" + $scope.ruleSelected.id).then(
          function () {
            $scope.ruleSelected = null;
            loadRules();
            report("urlAllowlistRuleRemoved");
          },
          function (response) {
            report("urlAllowlistRuleRemoveError", response, true);
          }
        );
      };

      /**
       * Reports the real verdict, whatever audit mode is set to, so that a rule
       * set can be checked before it is enforced.
       */
      $scope.runTest = function () {
        $http
          .get("../api/urlallowlist/test", {
            params: {
              url: $scope.testUrl,
              scope: ($scope.ruleSelected && $scope.ruleSelected.scope) || "GLOBAL"
            }
          })
          .then(
            function (response) {
              $scope.testResult = response.data;
            },
            function (response) {
              report("urlAllowlistTestError", response, true);
            }
          );
      };

      loadRules();
    }
  ]);
})();
