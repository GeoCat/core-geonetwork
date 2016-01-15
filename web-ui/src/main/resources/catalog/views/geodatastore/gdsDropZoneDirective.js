(function() {
  goog.provide('geodatastore_dropzone_directive')

  var module = angular.module('geodatastore_dropzone_directive', []);

  module.directive("gdsDropZone", ['$timeout', '$window', '$document', '$log',
    function($timeout, $window, $document, $log) {
      return {
        restrict: 'A',
        link: function(scope, element, attrs) {
          angular.element($document).bind('dragover', function(e) {
            var dropZone = $(element);
            var timeout = $window.dropZoneTimeout;
            if (!timeout) {
              dropZone.addClass('in');
            } else {
              $timeout.cancel(timeout);
            }
            var found = false;
            var node = e.target;

            do {
              if (node === dropZone[0]) {
                found = true;
                break;
              }
              node = node.parentNode;
            } while (node != null);

            if (found) {
              dropZone.addClass('hover');
            } else {
              dropZone.removeClass('hover');
            }
            $window.dropZoneTimeout = $timeout(function() {
                  $window.dropZoneTimeout = null;
                  dropZone.removeClass('in hover');
                },
                100);
          });

        }
      };

    }]);
})();