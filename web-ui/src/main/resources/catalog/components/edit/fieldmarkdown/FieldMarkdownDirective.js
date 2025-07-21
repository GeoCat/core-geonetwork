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
  /**
   * Directive for rendering a markdown field with syntax highlighting.
   * It uses angular-markdown-editor and hljs for rendering.
   *
   * @example
   * <div gn-field-markdown="fieldValue" ref="someRef" required="true" language="EN" tooltip="Markdown editor"></div>
   */

  module.directive("gnFieldMarkdown", [
    "$http",
    "$rootScope",
    function ($http, $rootScope) {
      return {
        restrict: "A",
        replace: true,
        transclude: true,
        scope: {
          value: "@gnFieldMarkdown",
          ref: "@ref",
          language: "@language",
          tooltip: "@tooltip"
        },
        templateUrl:
          "../../catalog/components/edit/fieldmarkdown/partials/" + "fieldmarkdown.html",
        link: function (scope, element, attrs) {
        }
      };
    }
  ]);
})();
