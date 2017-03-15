(function() {
    goog.provide('gds_registry_location_service');

    goog.require('geodatastore_api_urls');
    goog.require('gn_urlutils_service');

    var module = angular.module('gds_registry_location_service', ['geodatastore_api_urls', 'gn_urlutils_service']);

    module.factory('Keyword', function() {
        function Keyword(k) {
            this.props = $.extend(true, {}, k);
            this.label = this.getLabel();
            this.tagClass = 'label label-info gn-line-height';
        };
        Keyword.prototype = {
            getId: function() {
                return this.props.key;
            },
            getLabel: function() {
                return this.props['label'];
            }
        };

        return Keyword;
    });

    module.factory('Thesaurus', function() {
        function Thesaurus(k) {
            this.props = $.extend(true, {}, k);
        };
        Thesaurus.prototype = {
            getKey: function() {
                return this.props.key;
            },
            getTitle: function() {
                return this.props.title;
            }
        };

        return Thesaurus;
    });

    module.provider('gdsRegistryLocationService',
        function() {
            this.$get = [
                '$q',
                '$rootScope',
                '$http',
                'GDS_REGISTRY_LOCATION_URL',
                'Keyword',
                'Thesaurus',
                'gnUrlUtils',
                function($q, $rootScope, $http, GDS_REGISTRY_LOCATION_URL, Keyword, Thesaurus, gnUrlUtils) {
                    var getKeywordsSearchUrl = function(filter, max) {
                        return gnUrlUtils.append(GDS_REGISTRY_LOCATION_URL,
                            gnUrlUtils.toKeyValue({
                                pageSize: max,
                                q: filter || ''
                            })
                        );
                    };


                    var parseKeywordsResponse = function(data, dataToExclude) {
                        var listOfKeywords = [];
                        angular.forEach(data.response, function(k) {
                            if (k['label']) {
                                listOfKeywords.push(new Keyword(k));
                            }
                        });

                        if (dataToExclude && dataToExclude.length > 0) {
                            // Remove from search already selected keywords
                            listOfKeywords = $.grep(listOfKeywords, function(n) {
                                var isSelected = $.grep(dataToExclude, function(s) {
                                        return s.getLabel() === n.getLabel();
                                    }).length !== 0;
                                return !isSelected;
                            });
                        }
                        return listOfKeywords;
                    };


                    return {
                        /**
                         * Number of keywords returned by search (autocompletion
                         * or selection, ...)
                         */
                        DEFAULT_NUMBER_OF_RESULTS: 200,
                        /**
                         * Number of keywords to display in autocompletion list
                         */
                        DEFAULT_NUMBER_OF_SUGGESTIONS: 30,
                        getKeywordAutocompleter: function(config) {
                            var keywordsAutocompleter = new Bloodhound({
                                datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
                                queryTokenizer: Bloodhound.tokenizers.whitespace,
                                limit: config.max || this.DEFAULT_NUMBER_OF_RESULTS,
                                remote: {
                                    wildcard: 'QUERY',
                                    url: this.getKeywordsSearchUrl('QUERY',
                                        config.max || this.DEFAULT_NUMBER_OF_RESULTS),
                                    filter: function(data) {
                                        return parseKeywordsResponse(data, config.dataToExclude);
                                    }
                                }
                            });
                            keywordsAutocompleter.initialize();
                            return keywordsAutocompleter;
                        },
                        getKeywordsSearchUrl: getKeywordsSearchUrl,
                        /**
                         * Convert JSON response to array of Keyword object.
                         * Filter element if dataToExclude parameter defined.
                         */
                        parseKeywordsResponse: parseKeywordsResponse,
                        getKeywords: function(filter, thesaurus, max, typeSearch) {
                            var defer = $q.defer();
                            var url = getKeywordsSearchUrl(filter,
                                thesaurus, max, typeSearch);
                            $http.get(url, { cache: true }).
                            success(function(data, status) {
                                defer.resolve(parseKeywordsResponse(data));
                            }).
                            error(function(data, status) {
                                //                TODO handle error
                                //                defer.reject(error);
                            });
                            return defer.promise;
                        }

                    };
                }];
        });
})();
