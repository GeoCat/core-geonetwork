(function() {
  goog.provide('geodatastore_api_urls');

  var module = angular.module('geodatastore_api_urls', []);

  module.constant('NEW_DATASET_URL', '../../api/v1/dataset')
      .constant('UPDATE_DATASET_URL','../../api/v1/dataset/')
      .constant('DELETE_DATASET_URL', '../../api/v1/dataset/')
      .constant('QUERY_DATASETS_URL', '../../api/v1/datasets')
      .constant('NEW_ACCOUNT_URL', '../../web/dut/gdsRegister')
      .constant('GDS_AJAX_LOGIN_URL', '../dut/ajaxLogin');



})();
