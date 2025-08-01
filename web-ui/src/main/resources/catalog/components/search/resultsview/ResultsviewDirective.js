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

(function () {
  goog.provide("gn_resultsview");

  var module = angular.module("gn_resultsview", []);

  /**
   * @ngdoc directive
   * @name gn_resultsview.directive:gnResultsTplSwitcher
   *
   * @restrict A
   *
   * @description
   * The `gnResultsTplSwitcher` directive provides a button group
   * switcher to switch between customized views. The customs views
   * are defined in the UI admin settings. This config
   * defines a icon for the button, and a link to the html file
   * representing the desired view.
   *
   * The `gnResultsTplSwitcher` directive is used with the `gnResultsContainer`
   * directive that will load the custom view into its root html
   * element.
   */
  module.directive("gnResultsTplSwitcher", function () {
    return {
      require: "^ngSearchForm",
      templateUrl:
        "../../catalog/components/search/resultsview/partials/templateswitcher.html",
      restrict: "A",
      link: function ($scope, element, attrs, searchFormCtrl) {
        $scope.setResultTemplate = function (t) {
          $scope.resultTemplate = t;
          searchFormCtrl.triggerSearch(true);
        };
      }
    };
  });

  /**
   * @ngdoc directive
   * @name gn_resultsview.directive:gnResultsContainer
   *
   * @restrict A
   *
   * @description
   * The `gnResultsContainer` directive is used to load a custom
   * view (defined by a html file path) into its root element.
   */
  module.directive("gnResultsContainer", [
    "$compile",
    "gnMap",
    "gnOwsCapabilities",
    "gnSearchSettings",
    "gnMetadataActions",
    "gnConfig",
    "gnConfigService",
    "$http",
    function (
      $compile,
      gnMap,
      gnOwsCapabilities,
      gnSearchSettings,
      gnMetadataActions,
      gnConfig,
      gnConfigService,
      $http
    ) {
      return {
        restrict: "A",
        scope: true,
        link: function (scope, element, attrs, controller) {
          scope.mdService = gnMetadataActions;
          scope.map = scope.$eval(attrs.map);

          if (scope.map) {
            scope.hoverOL = new ol.layer.Vector({
              source: new ol.source.Vector(),
              style: gnSearchSettings.olStyles.mdExtentHighlight
            });

            /**
             * Draw md bbox on search
             */
            var fo = new ol.layer.Vector({
              source: new ol.source.Vector(),
              map: scope.map,
              style: gnSearchSettings.olStyles.mdExtent
            });
          }

          gnConfigService.load().then(function (c) {
            scope.isMdWorkflowEnable = gnConfig["metadata.workflow.enable"];
            scope.isInspireEnabled = gnConfig["system.inspire.enable"];
          });

          scope.$watchCollection("searchResults.records", function (rec) {
            //scroll to top
            element.animate({ scrollTop: top });

            // Initialize/reset an empty object to store group names
            scope.groupNames = {};

            // Check if there are any records
            if (rec && rec.length) {
              // Extract unique group owner IDs from the records
              var groupIds = [];
              var uniqueIds = {};

              for (var i = 0; i < rec.length; i++) {
                var groupOwner = rec[i].groupOwner;
                if (groupOwner && !uniqueIds[groupOwner]) {
                  uniqueIds[groupOwner] = true;
                  groupIds.push(groupOwner);
                }
              }

              // Fetch and store group names for each group ID
              for (var j = 0; j < groupIds.length; j++) {
                (function (groupId) {
                  gnMetadataActions.getGroupName(groupId).then(function (groupName) {
                    scope.groupNames[groupId] = groupName;
                  });
                })(groupIds[j]);
              }
            }

            // get md extent boxes
            if (scope.map) {
              fo.getSource().clear();

              if (!angular.isArray(rec) || angular.isUndefined(scope.map.getTarget())) {
                return;
              }
              for (var i = 0; i < rec.length; i++) {
                var feat = gnMap.getBboxFeatureFromMd(
                  rec[i],
                  scope.map.getView().getProjection()
                );
                fo.getSource().addFeature(feat);
              }
              var extent = ol.extent.createEmpty();
              fo.getSource().forEachFeature(function (f) {
                var g = f.getGeometry();
                if (g) {
                  ol.extent.extend(extent, g.getExtent());
                }
              });
              if (!ol.extent.isEmpty(extent)) {
                var viewExtent = ol.extent.createEmpty();

                // Get the search map background layer extent
                scope.map.getLayers().forEach(function (l) {
                  if (l.background == true) {
                    viewExtent = l.getExtent();
                  }
                });

                // check if the metadata extent is contained in the view extent
                if (viewExtent && !ol.extent.isEmpty(viewExtent)) {
                  if (ol.extent.containsExtent(viewExtent, extent)) {
                    // fit extent in map - zoom to the metadata extent
                    scope.map.getView().fit(extent, scope.map.getSize());
                  } else {
                    // fit extent in map - zoom to the view  extent
                    scope.map.getView().fit(viewExtent, scope.map.getSize());
                  }
                } else {
                  // fit extent in map - zoom to the metadata extent
                  scope.map.getView().fit(extent, scope.map.getSize());
                }
              }
            }
          });

          scope.$watch("resultTemplate", function (templateConfig) {
            if (angular.isUndefined(templateConfig)) {
              return;
            }
            var template = angular.element(document.createElement("div"));
            template.attr({
              "ng-include": "resultTemplate.tplUrl"
            });
            element.empty();
            element.append(template);
            $compile(template)(scope);
          });

          scope.zoomToMdExtent = function (md, map) {
            var feat = gnMap.getBboxFeatureFromMd(
              md,
              scope.map.getView().getProjection()
            );
            if (feat) {
              map.getView().fit(feat.getGeometry().getExtent(), map.getSize());
            }
          };

          scope.abstractBriefMaker = function (resourceAbstract) {
            if (resourceAbstract) {
              var abstractParagraphs = resourceAbstract.split("\n");
              var abstractBrief = "";
              for (var index = 0; index < abstractParagraphs.length; index++) {
                var abstractBrief = abstractBrief + abstractParagraphs[index] + "\n";
                if (abstractBrief.length > 50) {
                  break;
                }
              }

              //remove the last line break character
              return abstractBrief.substring(0, abstractBrief.length - 1);
            }
          };

          /**
           * @function displayWorkflowStatus
           * @description Checks if workflow is enabled and the group owner's name matches the workflow group regex.
           * @param {Object} md - The metadata object.
           * @returns {boolean} - Returns true if the group owner's name matches the workflow group regex and the workflow is enabled, otherwise false.
           */
          scope.displayWorkflowStatus = function (md) {
            // Return false if any required property is missing or workflow is not enabled
            if (!md.groupOwner || !scope.groupNames || !scope.isMdWorkflowEnable) {
              return false;
            }
            // Check if the group name matches the workflow group regex
            return (
              md.isWorkflowEnabled() ||
              gnMetadataActions.isGroupWithWorkflowEnabled(
                scope.groupNames[md.groupOwner]
              )
            );
          };

          if (scope.map) {
            scope.hoverOL.setMap(scope.map);
          }
        }
      };
    }
  ]);

  module.directive("gnDisplayextentOnhover", [
    "gnMap",
    function (gnMap) {
      return {
        restrict: "A",
        link: function (scope, element, attrs, controller) {
          //TODO : change, just apply a style to the feature when
          // featureoverlay is fixed
          var feat = new ol.Feature();

          element.bind("mouseenter", function () {
            var feat = gnMap.getBboxFeatureFromMd(
              scope.md,
              scope.map.getView().getProjection()
            );
            if (feat) {
              scope.hoverOL.getSource().addFeature(feat);
            }
          });

          element.bind("mouseleave", function () {
            scope.hoverOL.getSource().clear();
          });
        }
      };
    }
  ]);

  module.directive("gnZoomtoOnclick", [
    "gnMap",
    function (gnMap) {
      return {
        restrict: "A",
        link: function (scope, element, attrs, controller) {
          element.bind("dblclick", function () {
            scope.zoomToMdExtent(scope.md, scope.map);
          });
        }
      };
    }
  ]);
})();
