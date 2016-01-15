(function () {
  goog.provide('geodatastore_new_account_service');

  goog.require('geodatastore_api_urls');

  var module = angular.module('geodatastore_new_account_service', ['geodatastore_api_urls']);

  module.factory('GdsNewAccountFactory', [
    '$q',
    '$http',
    '$log',
    'NEW_ACCOUNT_URL',
    function ($q, $http, $log, NEW_ACCOUNT_URL) {
      var url = NEW_ACCOUNT_URL;
      var register = function(params, errorFn) {
        var parameters = angular.extend({}, params);
        var defer = $q.defer();
        $http.post(url, parameters
        ).success(function(data, status) {
          defer.resolve(data);
        }).error(function (data, status) {
          defer.reject(errorFn);
        });

        return defer.promise;
      };

      return {
        register: register
      };

    }]);


})();