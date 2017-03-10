(function() {
  goog.provide('gn_client_customs');

  var module = angular.module('gn_client_customs', []);

  module.filter('PDCFilter', function() {
    return function(input, noPDC) {   

      var out = [];

      angular.forEach(input, function(metadata) {

        var cat = metadata.category;

        if (angular.isArray(cat)) {
          if(noPDC) {
            if(cat.indexOf('PDC') === -1) {
              out.push(metadata);
            }
          } else {
            if(cat.indexOf('PDC') !== -1) {
              out.push(metadata);
            }
          }

        } else if(angular.isString(cat)) {              

          if(noPDC && cat != 'PDC') {
            out.push(metadata);
          } else if(!noPDC && cat === 'PDC') {
            out.push(metadata);
          }
        } else {
          if(noPDC) {
            out.push(metadata);
          } 
        }

      });

      return out;     
    }
  }); 

})();
