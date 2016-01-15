(function () {
  goog.provide('geodatastore_login');

  goog.require('gds_login_service');

  var module = angular.module('geodatastore_login', ['ui.bootstrap.showErrors', 'ngAnimate', 'gds_login_service']);
  module.config(['$animateProvider', function($animateProvider){
    // do not animate the elements with CSS class fa-spinner.
    $animateProvider.classNameFilter(/^((?!(fa-spinner)).)*$/);
  }]);

  module.controller('GdsLoginController', ['$rootScope', '$scope', '$http', 'gdsLoginService',
    function ($rootScope, $scope, $http, gdsLoginService) {

      $scope.loginForm = {};
      $scope.gdsLoginService = gdsLoginService;

      $scope.loadCatalogInfo();

      $rootScope.$on('unauthorized', function() {
        gdsLoginService.setSessionExpired(true);
      });


      $scope.login = function () {
        $scope.signinFailure = false;
        if ($scope.gnSigningForm.$valid) {
          $scope.loginWorking = true;
          gdsLoginService.login($.param($scope.loginForm)).then(
              function(data) {
                if (data.status === true) {
                  // We are logged-in
                  $scope.loadCatalogInfo().finally(function() {
                    $scope.signinFailure = false;
                    $scope.loginWorking = false;
                  });
                } else {
                  $scope.signinFailure = true;
                  $scope.loginWorking = false;
                }
              },
              function() {
                $scope.signinFailure = true;
                $scope.loginWorking = false;
              }
          ).finally(function() {
            $scope.loginWorking = false;
          });
        }
      };

    }]);

})();