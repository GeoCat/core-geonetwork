(function () {
  goog.provide('geodatastore_fileupload');

  goog.require('geodatastore_api_urls');
  goog.require('geodatastore_dropzone_directive');
  goog.require('geodatastore_upload_service');
  goog.require('format_file_size_filter');


  var module = angular.module('geodatastore_fileupload', [
    'geodatastore_api_urls', 'blueimp.fileupload', 'geodatastore_dropzone_directive',
    'geodatastore_upload_service', 'format_file_size_filter'
  ]);



  module.controller('GdsFileUploadController', ['$scope', 'GdsUploadFactory', 'NEW_DATASET_URL', '$translate',
    function ($scope, GdsUploadFactory, NEW_DATASET_URL, $translate) {
      $scope.GdsUploadFactory = GdsUploadFactory;

      /**
       * File upload callback for successful upload requests. his callback is the equivalent to the success callback
       * provided by jQuery ajax() and will also be called if the server returns a JSON response with an error property.
       *
       */
      var successfulUpload = function (e, data) {
        //console.log(data);
        if (!data.result.error) {
          GdsUploadFactory.add(data.result);
          $scope.clear(data.files);
        } else {
          failedUpload(e, data);
        }
      };

      var failedUpload = function (e, data) {
        var err = data.files[0];
        err.error = true;
        err.identifier = "error-" + Math.random();
        if (data.errorThrown) {
          err.status = data.errorThrown;
        }
        if (data.response() && data.response().jqXHR.responseJSON && data.response().jqXHR.responseJSON.messages) {
          err.message = data.response().jqXHR.responseJSON.messages[0];
        } else {
          err.message = "An error occurred";
        }
        GdsUploadFactory.add(err);
        $scope.clear(data.files);
      };


      $scope.datasetUploadOptions = {
        url: NEW_DATASET_URL,
        dropZone: $('#dropzone'),
        sequentialUploads: true,
        autoUpload: true,
        done: successfulUpload,
        fail: failedUpload,
        maxFileSize: 524300000,
        minFileSize: 1,
        messages: {
          maxFileSize: $translate('maxFileSizeError'),
          uploadedBytes: 'Uploaded bytes exceed file size'
        }
      };

    }]);

})();