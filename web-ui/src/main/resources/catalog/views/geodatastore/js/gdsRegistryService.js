(function() {
    goog.provide("geodatastore_registry_service");

    goog.require('geodatastore_api_urls');

    var module = angular.module('geodatastore_registry_service', ['geodatastore_api_urls']);

    module.service('gdsRegistryService', ['$q', '$http', 'GDS_REGISTRY_URL',
        function($q, $http, GDS_REGISTRY_URL) {
            var service = {};

            function genericRegistryQuery(registry) {
                var defer = $q.defer();
                var url = GDS_REGISTRY_URL + "/"+ registry;
                // Cache the first request. The following requests to the same URL will be retrieved from the cache.
                $http.get(url, { cache: true})
                    .success(function (data, status) {
                        if (data && data.response) {
                            defer.resolve(data.response);
                        } else {
                            defer.resolve(data);
                        }
                    }).error(function (data, status) {
                    defer.reject(data);
                });
                return defer.promise;
            }

            /**
             * Gets the license list from the server.
             * @returns {Promise} a promise that will be resolved with the license list.
             */
            service.getLicenses = function() {
                return genericRegistryQuery('license');
            };

            /**
             * Gets the denominators list from the server.
             * @returns {Promise} a promise that will be resolved with the denominator list on success or the error if
             * failed.
             */
            service.getDenominators = function () {
                return genericRegistryQuery('denominator');
            };

            service.getTopicCategories = function() {
                return genericRegistryQuery('topicCategory');
            };


            return service;
        }]);


})();