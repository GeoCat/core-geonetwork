(function () {
  goog.provide('geodatastore_readonly_metadata_controller');

  goog.require('geodatastore_upload_service');
  goog.require('geodatastore_api_urls');

  var module = angular.module('geodatastore_readonly_metadata_controller', [
    'geodatastore_api_urls',
    'geodatastore_upload_service',
    'pascalprecht.translate'
  ]);

  // Define the translation files to load
  module.constant('$LOCALES', ['geodatastore']);

  module.config(['$translateProvider', '$LOCALES',
    function ($translateProvider, $LOCALES) {
      $translateProvider.useLoader('localeLoader', {
        locales: $LOCALES,
        prefix: '../../catalog/views/geodatastore/locales/',
        suffix: '.json'
      });

      var lang = 'du';
      $translateProvider.preferredLanguage(lang);
      moment.lang(lang);
    }]);


  module.controller('GdsReadonlyMetadataController', ['$scope', 'GdsUploadFactory', '$log', '$translate', '$q',
    function ($scope, GdsUploadFactory, $log, $translate, $q) {
      $scope.GdsUploadFactory = GdsUploadFactory;

      $scope.mdSelected = null;



      $scope.$watch(function() {
        return GdsUploadFactory.getMdSelected();
      }, function (newValue, oldValue) {
        $log.debug("watch on GdsUploadFactory.getMdSelected changed");
        $scope.mdSelected = newValue;
      });


      $scope.getMdSelected = function () {
        return GdsUploadFactory.getMdSelected();
      };

      $scope.toggleEditMode = function() {
        $scope.editState.isEditing = !$scope.editState.isEditing;
        $log.debug("editMode toggled (editMode=" + $scope.editState.isEditing + ")");
      };

    }]);
})();