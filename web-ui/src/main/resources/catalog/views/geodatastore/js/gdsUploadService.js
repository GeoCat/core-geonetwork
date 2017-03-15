/**
 * Created by JuanLuis on 13/07/2015.
 */
(function () {
  goog.provide('geodatastore_upload_service');

  goog.require('geodatastore_api_urls');

  var module = angular.module('geodatastore_upload_service', ['geodatastore_api_urls']);

  module.factory('GdsUploadFactory', [
    '$q',
    '$http',
    '$log',
    'UPDATE_DATASET_URL',
    'DELETE_DATASET_URL',
    function ($q, $http, $log, UPDATE_DATASET_URL, DELETE_DATASET_URL) {
      var uploadedFiles = {};
      var selected = null;
      var mdDirty = false;

      uploadedFiles.setDirty = function (isDirty) {
        mdDirty = isDirty;
      };

      uploadedFiles.isDirty = function () {
        return mdDirty;
      }


      uploadedFiles.list = [];
      uploadedFiles.setMdSelected = function (md) {
        selected = md;
        //$log.debug("setMdSelected called: " + angular.toJson(md));
      };
      uploadedFiles.getMdSelected = function () {
        return selected;
      }

      uploadedFiles.add = function (file) {
        uploadedFiles.list.unshift(file);
      };

      uploadedFiles.clearList = function () {
        uploadedFiles.list = [];
      };

      uploadedFiles.removeFromList = function (file, listParam) {
        var lst = listParam || this.list;
        for (var i = lst.length - 1; i >= 0; i--) {
          var srMd = lst[i];
          if (srMd.identifier === file.identifier) {
            lst.splice(i, 1);
          }
        }
      };

      /**
       * Discover the file type using its extension or its fileType attribute if it is defined.
       * @param file a metadata object or a File object.
       * @returns {string} the CSS class name for the file type.
       */
      uploadedFiles.getFileIcon = function (file) {
        var type = 'unknown';
        if (file instanceof File) {
          type = file.type
        } else if (file instanceof String) {
          type = file;
        } else if (file && file.fileType) {
          type = file.fileType;
        }
        var iconClass = "fa-file-o";
        type = type.toLowerCase();
        if (type.includes("pdf")) {
          iconClass = "fa-file-pdf-o";
        } else if (type.startsWith("image/") || ["png", "gif", "jpg", "tiff", "tif", "jp2"].indexOf(file) >= 0) {
          iconClass = "fa-file-image-o";
        } else if (type.startsWith("video/")) {
          iconClass = "fa-file-video-o";
        } else if (type.startsWith("audio/")) {
          iconClass = "fa-file-audio-o";
        } else if (type.includes("zip") || type == "rar" || type.includes("compressed")) {
          iconClass = "fa-file-archive-o"
        } else if (type.includes("excel") || type.includes("sheet") || ["xls", "xlsx", "ods"].indexOf(file) >= 0) {
          iconClass = "fa-file-excel-o";
        } else if (type.includes("word") || type.includes("opendocument.text") || ["doc", "docx", "rtf"].indexOf(file) >= 0) {
          iconClass = "fa-file-word-o";
        } else if (type.includes("powerpoint") || type.includes("presentation") || ["ppt", "pptx"].indexOf(file) >= 0) {
          iconClass = "fa-file-powerpoint-o";
        } else if (type === "text/plain" || type === "application/rtf") {
          iconClass = "fa-file-text-o";
        } else if (["csv"].indexOf(file) >= 0) {
          iconClass = "pdok-i-csv";
        } else if (type === "text/css" || type === "text/html" || type === "application/rdf" || type === "application/rdf+xml"
            || type === "text/sgml" || type.includes("xml")) {
          iconClass = "fa-file-code-o";
        }
        return iconClass;
      };

	  setMessage = function(msg,modus){
		try{
		  if (!modus) modus = "success";
		  $("#msg-"+modus).children("span").html(msg).parent().show(500).delay(5000).hide(500);
		} catch (e) {}
	  }
	  
      /**
       * Save a metadata object to the server.
       * @param md metadata.
       * @oaran publish if server must try to publish the medatada.
       * @returns {*} a promise of the save operation. It will pass back the received data if success or the error object
       * if there is any problem at the server.
       */
      uploadedFiles.saveMetadata = function (md, publish) {

        var mustPublish = publish || false;
        var defer = $q.defer();
        if (md && md.identifier) {
          var mdToPublish = angular.extend({}, md);
          if (mdToPublish.topicCategory) {
            mdToPublish.topicCategories = [mdToPublish.topicCategory];
          }

          var request = new FormData();
          var url = UPDATE_DATASET_URL + mdToPublish.identifier;

          request.append("metadata", angular.toJson(mdToPublish));
          request.append("publish", mustPublish);
          $http.post(url, request, {
            transformRequest: angular.identity,
            headers: {'Content-Type': undefined}
          }).success(function (data) {
			
			if (!data){
				setMessage('Er is iets mis gegaan bij het opslaan','warning');
				return false;
			}
			
			//6 cases can occur:
			
			//data was already published 
			if (md && md.status==='published'){ 
				//data was not saved due to an error
				if (data.error){
					setMessage('Wijziging is niet opgeslagen, oude versie blijft gepubliceerd. '+((data.messages.length>0)?'Reden: '+data.messages[0]:''),'warning');
				//data was saved and published
				} else {
					setMessage('Data succesvol opnieuw gepubliceerd');
				}
			
			//data was not published yet
			} else {			
				//data was not saved due to an error
				if (data.error){	
					setMessage('Wijziging is niet opgeslagen. '+((data.messages&&data.messages.length>0)?'Reden: '+data.messages[0]:''),'warning');
				//data was saved but publish was not requested
				} else if (!publish){
					setMessage('Dataset informatie is opgeslagen');
				//data was saved but not published
				} else if (data.status !== 'published') {
					setMessage('Wijziging is opgeslagen maar dataset is niet gepubliceerd. '+((data.messages&&data.messages.length>0)?'Reden: '+data.messages[0]:''),'warning');
				//data was published succesfully
				} else {
					setMessage('Dataset is succesvol gepubliceerd. De dataset zal de volgende dag gepubliceerd zijn op het Nationaal Georegister en over 2 dagen eveneens op Data.overheid.nl.');
				}
				
			}			
			  
            if (data.error) {
              defer.reject(data);
            } else {
              defer.resolve(data);
            }
          }).error(function (error) {
            defer.reject(error);
          });
        } else {
          //$log.debug("GdsUploadService.saveMetadata -> No metadata or metadata without identifier");
        }
        return defer.promise;
      };


      uploadedFiles.replace = function (mdList, md) {
        var id = md.identifier;
        for (var i = 0; i < mdList.length; i++) {
          var mdInArray = mdList[i];
          if (mdInArray && mdInArray.identifier == id) {
            var copy = angular.copy(md);
            delete copy.saved;
            mdList[i] = copy;
          }
        }
      };

      uploadedFiles.deleteMetadata = function (md) {
        var defer = $q.defer();
        if (md && md.identifier) {
          var url = DELETE_DATASET_URL + md.identifier;
          $http.delete(url, {
            responseType: "json"
          }).success(function (data) {
            if (data.error) {
              defer.reject(data);
            } else {
              defer.resolve(data);
            }
          }).error(function (error) {
            if (error && error.error && error.error.message) {
              defer.reject({error: true, messages: [error.error.message]});
            } else {
              defer.reject(error);
            }
          });
        } else {
          defer.reject();
        }
        return defer.promise;
      };

      /**
       * Check if a metadata is publishable or not. For now it simply checks that all fields are filled.
       * @param metadata
       * @returns {boolean}
       */
      uploadedFiles.isPublishable = function (metadata) {
        var stringProperties = ['identifier', 'license', 'lineage', 'location', 'resolution', 'summary', 'title', 'url'];
        var arrayProperties = ['keywords', 'topicCategories'];
        var publishable = true;
        if (metadata) {
          // Check scalar properties
          for (var i = 0; i < stringProperties.length && publishable; i++) {
            var property = stringProperties[i];
            var propertyValue = metadata[property];
            if (!propertyValue || propertyValue.trim() == '') {
              publishable = false;
            }
          }

          // Check array properties
          for (var i = 0; i < arrayProperties.length && publishable; i++) {
            var property = arrayProperties[i];
            var propertyValue = metadata[property];
            if (!propertyValue || propertyValue.length == 0) {
              publishable = false;
            } else {
              for (var j = 0; j < propertyValue.length && publishable; j++) {
                var arrayValue = propertyValue[j];
                if (!arrayValue || arrayValue.trim() == '') {
                  publishable = false;
                }
              }
            }
          }
        } else {
          // no metadata so it is not publishable
          publishable = false;
        }

        return publishable;
      };

      uploadedFiles.getInvalidFields = function (metadata) {
        var stringProperties = ['identifier', 'license', 'lineage', 'location', 'resolution', 'summary', 'title', 'url'];
        var arrayProperties = ['keywords', 'topicCategories'];
        var badFields = [];
        if (metadata) {
          // Check scalar properties
          for (var i = 0; i < stringProperties.length; i++) {
            var property = stringProperties[i];
            var propertyValue = metadata[property];
            if (!propertyValue || propertyValue.trim() == '') {
              badFields.push(property);
            }
          }

          // Check array properties
          for (var i = 0; i < arrayProperties.length; i++) {
            var property = arrayProperties[i];
            var propertyValue = metadata[property];
            if (!propertyValue || propertyValue.length == 0) {
              badFields.push(property);
            } else {
              for (var j = 0; j < propertyValue.length; j++) {
                var arrayValue = propertyValue[j];
                if (!arrayValue || arrayValue.trim() == '') {
                  badFields.push(property);
                }
              }
            }
          }
        }
        return badFields;
      };


      return uploadedFiles;
    }]);

  module.factory('gdsSearchManagerService', [
    '$q',
    '$http',
    'QUERY_DATASETS_URL',
    function ($q, $http, QUERY_DATASETS_URL) {
      var url = QUERY_DATASETS_URL;

      var search = function (params, errorFn) {
        var parameters = params || {};
		//add a random val to prevent brower cache (todo: until proper nocache header is provided for IE)
		params.rnd=Math.random().toString().substr(2,8);
        var defer = $q.defer();
        $http.get(url, {
          params: parameters
        }).success(function (data, status) {
          defer.resolve(data);
        }).error(function (data, status) {
          defer.reject(errorFn);
		  setMessage('Ophalen datasets mislukt. '+((data.messages&&data.messages.length>0)?'Reden: '+data.messages[0]:''),'warning');
        });
        return defer.promise;
      };

      return {
        search: search
      };
    }
  ]);
})();

if (!String.prototype.endsWith) {
  String.prototype.endsWith = function (suffix) {
    return this.indexOf(suffix, this.length - suffix.length) !== -1;
  };
}

if (!String.prototype.startsWith) {
  String.prototype.startsWith = function (str) {
    return this.indexOf(str) == 0;
  }
}
if (!String.prototype.includes) {
  String.prototype.includes = function (str) {
    return this.indexOf(str) !== -1;
  };
}
