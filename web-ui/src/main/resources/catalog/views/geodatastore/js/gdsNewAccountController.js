(function () {
  goog.provide('geodatastore_new_account_controller');

  goog.require('geodatastore_new_account_service');
  goog.require('geodatastore_api_urls');
  goog.require('gn_cat_controller');
  goog.require('gn_utility_directive');



  var module = angular.module('geodatastore_new_account_controller', [
    'geodatastore_new_account_service',
    'blueimp.fileupload',
    'geodatastore_api_urls',
    'gn_utility_directive',
    'ui.bootstrap.showErrors'
  ]);


  module.controller('GdsNewAccountController', ['$scope', '$q', 'GdsNewAccountFactory', 'NEW_ACCOUNT_URL', '$log',
    function ($scope, $q, GdsNewAccountFactory, NEW_ACCOUNT_URL, $log) {
      $scope.registerBean = {
        title: 'mr'
      };

      $scope.isReadyToSubmit = function() {
        var valid = $scope.userinfo.$valid;
        valid = valid && $scope.queue.length == 1;
        /*$log.debug("Valid form: " + valid);*/
        return valid;
      };



      var getMetadataJson = function () {
        var data = angular.extend({}, $scope.registerBean);
        var metadata = [{
          name: 'registerBean',
          value: new Blob([angular.toJson(data)], {type: "application/json"})
        }
        ];
        return metadata;
      };

      $scope.processSubmit = function () {
        $scope.errors = false;
        $scope.success = false;
        $scope.globalError = null;
        if ($scope.queue && $scope.queue.length == 1) {
          // call submit in blueimp.fileupload
          $scope.uploadDeferred = $q.defer();
          $scope.submit();
          return $scope.uploadDeferred.promise;
        }
      };

      var successfulUpload = function(e, data) {
        $log.debug('Data successfully uploaded. Response: ' + data.result);
        if (data.result && data.result.status === 'SUCCESS') {
          $scope.success = true;
        } else if (data.result && data.result.status === 'ERROR') {
          $scope.success = false;
          var fieldsWithErrorsList = data.result.errorMessageList;
          // Set returned fields as invalid.
          if (fieldsWithErrorsList.length > 0) {
            $scope.errors = true;
          }
          angular.forEach(fieldsWithErrorsList, function(value, key) {
            var field = this[value];
            if (field) {
              field.$setValidity('required', false);
            }
          }, $scope.userinfo);

          if (data.result && data.result.globalError && data.result.globalError.length > 0) {
            $scope.globalError = data.result.globalError;
          }
        }
      };

      var failedUpload = function(e, data) {
        $log.warn('Data upload failed. Response: ' + data.errorThrown);
        $scope.success = false;
        $scope.errors = true;
      };

      var filesChanged = function(e, data) {
        $log.debug('filesChanged');
        if ($scope.queue.length > 0) {
          var file = $scope.queue.pop();
          $log.debug("File removed from queue: " + file);
        }
      };
      var always = function(e, data) {
        if ($scope.uploadDeferred) {
          $scope.uploadDeferred.resolve(data);
        }
      };


      $scope.newAccountOptions = {
        url: NEW_ACCOUNT_URL,
        type: 'POST',
        sequentialUploads: true,
        autoUpload: false,
        dataType: 'json',
        formData: getMetadataJson,
        done: successfulUpload,
        fail: failedUpload,
        change: filesChanged,
        always: always,
        acceptFileTypes: /(\.|\/)(png)$/i,
        previewMaxWidth: 100,
        previewMaxHeight: 100,
        previewCrop: false,
        maxNumberOfFiles: 1
      };



    }]);
})();