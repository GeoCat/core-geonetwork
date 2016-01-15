(function () {

  goog.provide('gn_search_geodatastore');


  goog.require('gn_search');
  goog.require('gn_search_geodatastore_config');
  goog.require('gn_search_geodatastore_directive');
  goog.require('gn_login_controller');
  goog.require('gn_utility_directive');
  goog.require('geodatastore_login');
  goog.require('geodatastore_fileupload');
  goog.require('geodatastore_upload_service');
  goog.require('geodatastore_edit_metadata_controller');
  goog.require('geodatastore_readonly_metadata_controller');

  var module = angular.module('gn_search_geodatastore',
      ['geodatastore_fileupload', 'gn_search', 'geodatastore_login', 'gn_login_controller', 'ngRoute', 'gn_search_geodatastore_config',
        'gn_search_geodatastore_directive', 'gn_mdactions_directive', 'geodatastore_upload_service', 'bootstrap-tagsinput',
        'geodatastore_edit_metadata_controller', 'gn_utility_directive', 'pascalprecht.translate', 'ui.bootstrap.modal', 'ngAnimate',
        'ui.bootstrap.tooltip', 'geodatastore_readonly_metadata_controller']);

  // Define the translation files to load
  module.constant('$LOCALES', ['geodatastore']);
  module.factory('sessionInterceptor', ['$q', '$injector', '$log', '$rootScope', function($q, $injector, $log, $rootScope) {
    var sessionInterceptor = {
      'request': function(config) {
        $log.debug('Request to ' + config.url);
        return config;
      },
      'responseError': function (rejection) {
        // Session has expired
        if (rejection.status == 401) {
          $log.warn("Session expired");
          var originalData = rejection.data;
          rejection.data = {};
          rejection.data.error = true;
          rejection.data.messages = ['server.session.timeout'];
          rejection.data.originalData = originalData;
          rejection.data.reqStatus = rejection.status;
          $rootScope.$broadcast('loadCatalogInfo');
          $rootScope.$broadcast('unauthorized');

        }

        return $q.reject(rejection);
      }
    };
    return sessionInterceptor;
  }]);

  module.config(['$translateProvider', '$LOCALES', '$httpProvider',
    function ($translateProvider, $LOCALES, $httpProvider) {
      $translateProvider.useLoader('localeLoader', {
        locales: $LOCALES,
        prefix: '../../catalog/views/geodatastore/locales/',
        suffix: '.json'
      });

      //var lang = location.href.split('/')[5].substring(0, 2) || 'en';
      var lang = 'du';
      $translateProvider.preferredLanguage(lang);
      moment.lang(lang);

      // Config $httpProvider interceptor
      $httpProvider.interceptors.push('sessionInterceptor');


    }]);





  module.controller('geoDataStoreMainController', [
    '$scope',
    '$rootScope',
    '$http',
    '$translate',
    '$log',
    '$filter',
    'gnUtilityService',
    'gnSearchSettings',
    'gnViewerSettings',
    'Metadata',
    'gdsSearchManagerService',
    'GdsUploadFactory',
    '$modal',
    '$q',
    function ($scope, $rootScope, $http, $translate, $log, $filter,
              gnUtilityService, gnSearchSettings, gnViewerSettings, Metadata, gdsSearchManagerService, GdsUploadFactory,
              $modal, $q) {


      $scope.loadCatalogInfo();

      $scope.editState = {
        isEditing: true
      };

      $scope.searchResults = {records: [], metadata: []};
      $scope.totalNotPublished = 0;
      $scope.totalPublished = 0;
      $scope.GdsUploadFactory = GdsUploadFactory;
      $scope.tab = "upload";
      $scope.ngr_url = 'http://www.nationaalgeoregister.nl/geonetwork';
      //gn.ngr-url is defined by a param in loadjscss.xsl, which should be filled by deploy-it, else it will contain '{{' 
      //if (!$scope.ngr_url || $scope.ngr_url.indexOf('{{')>-1) $scope.ngr_url = 'http://www.nationaalgeoregister.nl/geonetwork';
      $scope.perPage = 8;
      $scope.page = 1;
      $scope.searchParams = {
        selectedOrder: 'changeDate',
        searchQuery: null,
        sortDirection: 'desc'
      };

      $scope.orderList = [
        {
          fieldName: '_title',
          labelKey: 'title'
        }, {
          fieldName:'changeDate',
          labelKey: 'changeDate'
        }];

      $scope.orderListUpload = [
        {
          fieldName:'changeDate',
          labelKey: 'changeDate'
        }];

      $scope.$watch('authenticated', function (newValue) {
        if (newValue) {
          $scope.getResultsSummary('draft');
          $scope.getResultsSummary('published');
          $scope.updateResults(1);
        }
      });

      $rootScope.$on('unauthorized', function() {
        $scope.hasSelected = false;
        GdsUploadFactory.setMdSelected(null);
        GdsUploadFactory.clearList();
        GdsUploadFactory.setDirty(false);
        $scope.tab = 'upload';
      })

      $scope.sortResults = function() {
        var query = $scope.searchParams.searchQuery;
        var page = $scope.page;
        var fieldOrder = $scope.searchParams.selectedOrder;
        var direction = $scope.searchParams.sortDirection;
        if (!$scope.page || isNaN($scope.page)) {
          page = 1;
        }

        return $scope.updateResults(page, query, fieldOrder, direction);
      };

      $scope.toggleSortOrder = function() {
        if ($scope.searchParams.sortDirection === 'desc') {
          $scope.searchParams.sortDirection = 'asc';
        } else {
          $scope.searchParams.sortDirection = 'desc';
        }
        $scope.sortResults();
      };

      $scope.search = function() {
        var searchQuery = $scope.searchParams.searchQuery;
        var page = 1;
        var sortOrder = $scope.searchParams.selectedOrder;
        var sortDirection = $scope.searchParams.sortDirection;
        return $scope.updateResults(page, searchQuery, sortOrder, sortDirection);
      };

      $scope.clearSearch = function () {
        $scope.searchParams.searchQuery = null;
        return $scope.search();
      }

      $scope.searchFromKeypress = function(evt) {
        if (evt.which === 13) {
          evt.preventDefault();
          $scope.search();
        }
      };



      $scope.$watch('tab', function (newValue, oldValue) {
        // Retrieve the register count for the not selected tab.
        if (newValue) {
          $scope.resetAll(newValue);
        }
      });
      $scope.resetAll = function(newValue) {
        $scope.searchParams = {
          selectedOrder: 'changeDate',
          searchQuery: null,
          sortDirection: 'desc'
        };
        $scope.page = 1;
        $scope.getResultsSummary('draft');
        $scope.getResultsSummary('published');
        $scope.hasSelected = false;
        GdsUploadFactory.setMdSelected(null);
        GdsUploadFactory.clearList();
        GdsUploadFactory.setDirty(false);
        $scope.updateResults(1);
        $scope.resetEditState(newValue);
      };

      $scope.updateResultsAndPreserveSearch = function(page) {
        $scope.updateResults(page, $scope.searchParams.searchQuery, $scope.searchParams.selectedOrder,
            $scope.searchParams.sortDirection);
      };

      $scope.updateResults = function (page, any, order, sortDirection) {
        $scope.page = page;
        var orderParam = order;
        if (!order) {
          orderParam = "changeDate";
        }
        var searchParams = {
          from: (page - 1) * $scope.perPage + 1,
          sortBy: orderParam,
          sortOrder: 'desc',
          pageSize: $scope.perPage,
          status: ($scope.tab === 'upload') ? 'draft' : 'published'
        };

        if (any) {
          $scope.filterActive = true;
         /* var queryObject = {};
          queryObject['title_OR_abstract'] = any;*/
          angular.extend(searchParams, {q: "*"+any+"*"});
        } else {
          $scope.filterActive = false;
        }
        if (sortDirection) {
          angular.extend(searchParams, {sortOrder: sortDirection});
        }


        $scope.searching = true;
        gdsSearchManagerService.search(searchParams).then(function (data) {
          GdsUploadFactory.clearList();
          $scope.searchResults = data;
          $scope.filterCount = data.count?data.count:0;
          if ($scope.tab === 'upload' && data.count && data.count>-1) {
            $scope.totalNotPublished = data.count?data.count:0;
          } else if ($scope.tab === 'published' && data.count>-1) {
            $scope.totalPublished = data.count?data.count:0;
          }
          var cnt = Math.ceil(data.count / $scope.perPage);
          if (!cnt || cnt < 1) cnt = 1;
          $scope.pages = new Array(cnt);
        }, function (error) {
          $log.error("Error in search: " + error);
        }).finally(function() {
          $scope.searching= false;
        });
      };

      $scope.getResultsSummary = function (status) {
        gdsSearchManagerService.search({
          status: status,
          summaryOnly: true
        }).then(function (data) {
          if (status === 'draft') {
            $scope.totalNotPublished = data.count?data.count:0;
          } else if (status === 'published') {
            $scope.totalPublished = data.count?data.count:0;
          }
        })
      }

      //get the status of a dataset, a dataset can be published if all fields are completed
      $scope.getStatus = function (md) {
        if (md.$publishable) {
          return 'publish';
        } else if (md.error) {
          return 'error';
        } else {
          return 'metadataMissing';
        }
      };

      $scope.pages = [];
      $scope.updateResults(1);
      //$scope.mdSelected;
      $scope.hasSelected = false;
      $scope.formModified = false;

      $scope.setMD = function (md) {
        //$log.debug(md);

        var selectedInService = GdsUploadFactory.getMdSelected();

        // If you are trying to change selected card and edit form is dirty, ask user what to do with changes
        if (GdsUploadFactory.isDirty() && selectedInService && selectedInService.identifier && selectedInService.identifier !== md.identifier) {
          //$log.debug("Show confirmation modal");
          var modalInstance = $modal.open({
            scope: $scope,
            templateUrl: '../../catalog/views/geodatastore/templates/dirtyFormModal.html',
            controller: 'ChangeCardModalController',
            resolve: {
              metadata: function () {
                return md;
              }
            }
          });

          modalInstance.result.then(
              function(md) {
                GdsUploadFactory.setDirty(false);
                $scope.$setMdSelected(md);
              },
              function () {
                //$log.debug("Card change cancelled");
              }
          );

        } else {
          $scope.$setMdSelected(md);
        }
      };

      /**
       * Reset the edit state depending on the tab selected.
       */
      $scope.resetEditState = function(selectedTab) {
        if (!GdsUploadFactory.isDirty()) {

          if (selectedTab === 'upload') {
            $scope.editState.isEditing = true;
          } else if (selectedTab === 'published') {
            $scope.editState.isEditing = false;
          }
        }
      };

      $scope.$setMdSelected = function (md) {
        GdsUploadFactory.setMdSelected(angular.copy(md));
        if (md.topicCategories && md.topicCategories.length > 0) {
          GdsUploadFactory.getMdSelected().topicCategory = $filter('orderBy')(GdsUploadFactory.getMdSelected().topicCategories)[0];
        } else {
          GdsUploadFactory.getMdSelected().topicCategory = null;
        }
        $scope.hasSelected = true;
        if (!GdsUploadFactory.isDirty()) {
          $scope.resetEditState($scope.tab);
        }
      };

      $scope.getMdSelected = function () {
        return GdsUploadFactory.getMdSelected();
      };

      $scope.getTopicCategoryAsString = function () {
        var selected = GdsUploadFactory.getMdSelected();
        if (selected) {
          return selected.topicCategory;
        }
        else {
          return undefined;
        }
      };

      $scope.$watch($scope.getTopicCategoryAsString, function (newValue, oldValue) {
        //$log.debug("topicCategory changed: " + oldValue + "--> " + newValue);
        var selected = GdsUploadFactory.getMdSelected();
        if (selected) {
          if (newValue !== null && newValue !== undefined) {
            selected.topicCategories = [newValue];
          } else {
            selected.topicCategories = [];
          }
        }
      });

      //grab the filetype either from format or from file extension
      $scope.getFileType = function (md) {
        var ftype = "";
        if (md instanceof File && md.name.split(".").length > 1) {
          ftype = md.name.split('.')[md.name.split('.').length-1];
        } else if (md.fileType && md.fileType != '') {
           ftype = md.fileType;
        } else if (md.fileName && md.fileName.split('.').length > 1){	
            ftype = md.fileName.split('.')[md.fileName.split('.').length-1];	
        } else {
            ftype = "";
        }
        return GdsUploadFactory.getFileIcon(ftype);
      };

      $scope.setBackground = function (md) {
        var mdIdentifier = md.identifier || md['geonet:info'].uuid;
        var selectedIdentifier = null;
        if ($scope.hasSelected) {
          if (GdsUploadFactory.getMdSelected().identifier) {
            selectedIdentifier = GdsUploadFactory.getMdSelected().identifier;
          } else if (GdsUploadFactory.getMdSelected()['geonet:info'] && $scope.mdSelected['geonet:info'].uuid) {
            selectedIdentifier = GdsUploadFactory.getMdSelected()['geonet:info'].uuid;
          }
        }
        if (mdIdentifier == selectedIdentifier) {
          return 'modify';
        } else {
          return null;
        }
      };

      /**
       * Set the active tab.
       * @param val current tab.
       */
      $scope.setTab = function (val) {
        //if form modified && not saved, warn to loose changes?
        $scope.tab = val;
      };

      //grab the filename from metadata, for now take the first link, later check which link is the correct link, sometimes filename is empty then use file desc
      $scope.getFileName = function (md) {
        if (md instanceof File) {
          return md.name;
        } else if (md.fileName && md.fileName.length > 0) {
          return md.fileName;
        } else {
            return md.title;
        }
      };

      $scope.saveMetadata = function () {
        GdsUploadFactory.saveMetadata(GdsUploadFactory.getMdSelected()).then(
            function () {
            },
            function (error) {
            });
      };

      $scope.publishMetadata = function (md) {
        return GdsUploadFactory.saveMetadata(md, true).then(
            function (data) {
              if (data.status === 'published') {
                GdsUploadFactory.removeFromList(md, $scope.searchResults.metadata);
                GdsUploadFactory.removeFromList(md);
                $scope.totalPublished = $scope.totalPublished + 1;
                $scope.totalNotPublished = $scope.totalNotPublished - 1;
                if (GdsUploadFactory.getMdSelected() && GdsUploadFactory.getMdSelected().identifier === md.identifier) {
                  GdsUploadFactory.setMdSelected({});
                  $scope.hasSelected = false;
                }
			  }
            }, function (error) {
              var modalInstance = $modal.open({
                templateUrl: '../../catalog/views/geodatastore/templates/publishFormModal.html',
                controller: 'PublishModalController',
                resolve: {
                  metadata: function () {
                    return error;
                  }
                }
              });
              modalInstance.result;
            }
        );
      };

      $scope.showDeleteConfirm = function (md, evt) {
        if (evt) {
          evt.stopPropagation();
        }
        var modalInstance = $modal.open({
          scope: $scope,
          templateUrl: '../../catalog/views/geodatastore/templates/deleteFormModal.html',
          controller: 'ConfirmDeletedModalController',
          resolve: {
            metadata: function () {
              return md;
            }
          }
        });
        modalInstance.result.then(
            function (result) {
              // User clicks on Delete button in modal
              GdsUploadFactory.removeFromList(result);
              for (var i = $scope.searchResults.metadata.length - 1; i >= 0; i--) {
                var srMd = $scope.searchResults.metadata[i];
                if (GdsUploadFactory.getMdSelected() && (result.identifier === GdsUploadFactory.getMdSelected().identifier)) {
                  $scope.hasSelected = false;
                  GdsUploadFactory.setMdSelected({});
                }
                if (srMd.identifier === result.identifier) {
                  $scope.searchResults.metadata.splice(i, 1);
                  if ($scope.tab === 'upload' && $scope.totalNotPublished>-1) {
                    $scope.totalNotPublished = $scope.totalNotPublished - 1;
                  } else  if ($scope.tab === 'published' && $scope.totalPublished>-1) {
                    $scope.totalPublished = $scope.totalPublished - 1;
                  }
                  if ($scope.filterActive && $scope.filterCount) {
                    $scope.filterCount = $scope.filterCount - 1;
                  }
                }
              }
              return result;
            }, function (dismiss) {
              return $q.reject(dismiss);
            }
        );
      };

    }]);

  module.controller('ChangeCardModalController', ['$scope', '$modalInstance', 'metadata',
    function ($scope, $modalInstance, metadata) {

      $scope.metadata = metadata;

      $scope.changeCard = function () {
        $modalInstance.close($scope.metadata);
      };
    }]);

  module.controller('ConfirmDeletedModalController', ['$scope', '$modalInstance', 'metadata', 'GdsUploadFactory',
    function ($scope, $modalInstance, metadata, GdsUploadFactory) {
      $scope.acceptDelete = function () {
        $scope.deleteWorking = true;
        return GdsUploadFactory.deleteMetadata(metadata).then(function () {
          $scope.deleteWorking = false;
          return $modalInstance.close(metadata);
        }, function (error) {
          $scope.deleteWoring = false;
          $scope.deleteError = true;
          $scope.deleteErrorMessages = error.messages;
        });
      }
    }
  ]);

  module.controller('PublishModalController', ['$scope', '$modalInstance', 'metadata', function ($scope, $modalInstance, metadata) {
    $scope.publishErrorMessages = metadata.messages;
  }]);

  module.controller('gdsCardController', ['$scope', 'GdsUploadFactory', function ($scope, GdsUploadFactory) {
    // watch md object for changes and evaluate if it is publishable. Then save this state to md.$publishable property.
    // $publishable starts with a '$' character so it is not take in account for detecting object changes
    $scope.$watch('md', function (newValue, oldValue) {
      if (newValue) {
        var isPublishable = GdsUploadFactory.isPublishable(newValue);
        newValue.$publishable = isPublishable;
      }

    }, true);

    $scope.startPublish = function (evt) {
      if (evt) {
        evt.stopPropagation();
      }

      return $scope.publishMetadata($scope.md);
    }
  }]);


  module.controller("geoDataStoreController", ['$scope', function ($scope) {

  }]);


})();
