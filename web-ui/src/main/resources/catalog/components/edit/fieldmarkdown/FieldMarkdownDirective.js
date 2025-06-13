(function () {
  goog.provide("gn_field_markdown_directive");

  var module = angular.module("gn_field_markdown_directive", [
    "hc.marked",
    "hljs",
    "angular-markdown-editor"
  ]);

  module.config([
    "markedProvider",
    "hljsServiceProvider",
    function (markedProvider, hljsServiceProvider) {
      // marked config
      markedProvider.setOptions({
        gfm: true,
        tables: true,
        sanitize: true,
        highlight: function (code, lang) {
          if (lang) {
            return hljs.highlight(lang, code, true).value;
          } else {
            return hljs.highlightAuto(code).value;
          }
        }
      });

      // highlight config
      hljsServiceProvider.setOptions({
        // replace tab with 4 spaces
        tabReplace: "    "
      });
    }
  ]);

  module.directive("gnFieldMarkdownDiv", [
    "$http",
    "$rootScope",
    function ($http, $rootScope) {
      return {
        restrict: "A",
        replace: true,
        transclude: true,
        scope: {
          value: "@gnFieldMarkdownDiv",
          label: "@label",
          ref: "@ref",
          required: "@required"
        },
        templateUrl:
          "../../catalog/components/edit/fieldmarkdown/partials/" + "fieldmarkdown.html",
        link: function (scope, element, attrs) {}
      };
    }
  ]);
})();
