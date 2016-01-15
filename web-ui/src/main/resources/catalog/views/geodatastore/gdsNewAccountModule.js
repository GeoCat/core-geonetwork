(function() {
  goog.provide('geodatastore_new_account');

  goog.require('gn');
  goog.require('gn_search_manager');
  goog.require('gn_catalog_service');
  goog.require('gn_utility_service');
  goog.require('geodatastore_new_account_controller');
  goog.require('geodatastore_new_account_service');


  var module = angular.module('geodatastore_new_account', [
    'gn',
    'gn_search_manager',
    'gn_catalog_service',
    'gn_utility_service',
    'geodatastore_new_account_service',
    'geodatastore_new_account_controller'
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



})();