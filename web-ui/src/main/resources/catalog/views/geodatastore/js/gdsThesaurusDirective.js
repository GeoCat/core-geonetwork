(function () {
  goog.provide('gds_thesaurus_directive');


  goog.require('gn_thesaurus_service');


  var module = angular.module('gds_thesaurus_directive', ['gn_thesaurus_service']);

  /**
   * @ngdoc directive
   * @name gn_thesaurus.directive:gnKeywordPicker
   * @function
   *
   * @description
   * Provide simple keyword search.
   *
   * We can't transclude input (http://plnkr.co/edit/R2O2ixWA1QJUsVcUHl0N)
   */
  module.directive('gdsKeywordPicker', [
    'gnThesaurusService', '$compile', '$translate',
    function (gnThesaurusService, $compile, $translate) {
      return {
        restrict: 'A',
        require: '?ngModel',  // The two-way data bound value that is returned by the directive
        scope: {
          uriModel: '=uriModel'
        },
        link: function (scope, element, attrs, ngModel) {
          scope.thesaurusKey = attrs.thesaurusKey || '';
          scope.max = gnThesaurusService.DEFAULT_NUMBER_OF_RESULTS;
          var initialized = false;

          // Create an input group around the element
          // with a thesaurus selector on the right.
          var addThesaurusSelectorOnElement = function () {
            var inputGroup = angular.
                element('<div class="input-group"></div>');
            var dropDown = angular.
                element('<div class="input-group-btn"></div>');
            // Thesaurus selector is a directive
            var thesaurusSel = '<span data-gn-thesaurus-selector="" ' +
                'data-selector-only="true"></span>';

            var input = element.replaceWith(inputGroup);
            inputGroup.append(input);
            inputGroup.append(dropDown);
            // Compile before insertion
            dropDown.append($compile(thesaurusSel)(scope));
          };


          var init = function () {
            // Get list of available thesaurus (if not defined
            // by scope)
            element.typeahead('destroy');
            element.attr('placeholder', $translate('searchOrTypeKeyword'));

            // Thesaurus selector is not added if the key is defined
            // by configuration
            if (!initialized && !attrs.thesaurusKey) {
              addThesaurusSelectorOnElement(element);
            }
            var keywordsAutocompleter =
                gnThesaurusService.getKeywordAutocompleter({
                  thesaurusKey: scope.thesaurusKey
                });

            // Init typeahead
            element.typeahead({
              minLength: 0,
              highlight: true
              // template: '<p>{{label}}</p>'
              // TODO: could be nice to have definition
            }, {
              name: 'keyword',
              displayKey: 'label',
              source: keywordsAutocompleter.ttAdapter()
            });

            // When clicking the element trigger input
            // to show autocompletion list.
            // https://github.com/twitter/typeahead.js/issues/798
            element.on('typeahead:opened', function () {
              var initial = element.val(),
                  ev = $.Event('keydown');
              ev.keyCode = ev.which = 40;
              element.trigger(ev);
              if (element.val() != initial) {
                element.val('');
              }
              return true;
            });

            var updateScope = function (object, suggestion, dataset) {
              scope.$apply(function () {
                var newViewValue = suggestion;
                ngModel.$setViewValue(newViewValue.label);
                scope.uriModel = suggestion.props.uri;
              });
            }

            // Update the value binding when a value is manually selected from the dropdown.
            element.bind('typeahead:selected', function (object, suggestion, dataset) {
              updateScope(object, suggestion, dataset);
              scope.$emit('typeahead:selected', suggestion, dataset);
            });

            // Update the value binding when a query is autocompleted.
            element.bind('typeahead:autocompleted', function (object, suggestion, dataset) {
              updateScope(object, suggestion, dataset);
              scope.$emit('typeahead:autocompleted', suggestion, dataset);
            });

            initialized = true;
          };

          init();

          scope.$watch('thesaurusKey', function (newValue) {
            init();
          });
        }
      }
    }]);
})();