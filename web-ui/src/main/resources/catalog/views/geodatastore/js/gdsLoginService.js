(function() {
  goog.provide('gds_login_service');

  goog.require('geodatastore_api_urls');

  var module = angular.module('gds_login_service', ['geodatastore_api_urls']);

  module.service('gdsLoginService', [
    '$q',
    '$http',
    '$log',
    'GDS_AJAX_LOGIN_URL',
    function ($q, $http, $log, GDS_AJAX_LOGIN_URL) {
      var url = GDS_AJAX_LOGIN_URL;
      var sessionExpired = false;

      var isSessionExpired = function() {
        return sessionExpired;
      };

      var setSessionExpired = function(newVal) {
        sessionExpired = newVal;
      }

      var login = function (params, errorFn) {
        var defer = $q.defer();
        $http.post(url,
            params,
            {
              headers: {'Content-Type': 'application/x-www-form-urlencoded'}
            }
        ).success(function (data, status) {
          sessionExpired = false;
          $log.debug("Login response received.")
          defer.resolve(data);
        }).error(function (data, status) {
          $log.debug("Error in login response.")
          defer.reject(errorFn);
        });

        return defer.promise;
      };

      return {
        'login': login,
        'isSessionExpired': isSessionExpired,
        'setSessionExpired': setSessionExpired
      };
    }]);

})();