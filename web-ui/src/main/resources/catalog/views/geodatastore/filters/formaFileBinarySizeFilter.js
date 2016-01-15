(function () {
  goog.provide('format_file_size_filter');

  var module = angular.module('format_file_size_filter', []);

  module.filter('formatFileBinarySize', function() {
    var configuration = {
      // Byte units following the IEC format
      // http://en.wikipedia.org/wiki/Kilobyte
      decimalUnits: [
        {size: 1000000000, suffix: ' GB'},
        {size: 1000000, suffix: ' MB'},
        {size: 1000, suffix: ' KB'}
      ],
      binaryUnits: [
        { size: 1073741824, suffix: ' GiB' },
        { size: 1048576, suffix: ' MiB' },
        { size: 1024, suffix: ' KiB' }
      ]
    };
    return function (input, binary) {
      var $config = {};
      $config.units = configuration.decimalUnits;
      if (binary) {
        $config.units = configuration.binaryUnits;
      }
      if (!angular.isNumber(input)) {
        return '';
      }
      var unit = true,
          i = 0,
          prefix,
          suffix;
      while (unit) {
        unit = $config.units[i];
        prefix = unit.prefix || '';
        suffix = unit.suffix || '';
        if (i === $config.units.length - 1 || input >= unit.size) {
          return prefix + (input / unit.size).toFixed(2) + suffix;
        }
        i += 1;
      }

    };

  });


})();