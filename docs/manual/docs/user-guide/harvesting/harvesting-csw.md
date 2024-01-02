# Harvesting CSW services

This harvester will connect to a remote CSW server and retrieve metadata records that match the query parameters specified.

## Adding a CSW harvester

Configuration options:

- **Identification**:
    - *Name* - This is a short description of the remote site. It will be shown in the harvesting main page as the name for this instance of the harvester.
    - *Group* - Group that owns the harvested metadata.
    - *User* - User that owns the harvested metadata.
    - *Action on UUID collision* - Allows to configure the action when a harvester finds the same uuid on a record collected by another method (another harvester, importer, dashboard editor,...).
        - skipped (default)
        - overriden
        - generate a new UUID
- **Schedule** - Schedule configuration to execute the harvester.
- **Configuration for protocol OGC CSW 2.0.2**:
    - *Service URL* - The URL of the capabilities document of the CSW server to be harvested. eg. `http://geonetwork-site.com/srv/eng/csw?service=CSW&request=GetCabilities&version=2.0.2`. This document is used to discover the location of the services to call to query and retrieve metadata.
    - *Search filter* - Using the Add button, you can add several search criteria.
    - *XPath filter* - When record is retrieved from remote server, check an XPath expression to accept or discard the record. The XPath must use namespaces of the schema of the record (eg. `gmd`, `gco`, `srv` for ISO19139) and must return a boolean value. For example, to filter record with status = completed `count(.//gmd:status/*[@codeListValue = 'completed']) > 0`.
- **Advanced options for protocol CSW**:
    - *Remote authentication* - Account credentials for basic HTTP authentication on the CSW server.
    - *Check for duplicate resources based on the resource identifier* - Checks if exists another metadata with the same resource identifier, discarding the harvested metadata in such case. Comparison is made on the element `gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:identifier/*/gmd:code/gco:CharacterString`. It only applies to records in ISO19139 or ISO profiles.
    - *Category for harvested records* - The harvested metadata will be assigned to the selected category.
    - *Validate records before import* - If checked, the metadata will be validated after retrieval. If the validation does not pass, the metadata will be skipped.
- **Privileges** - Assign privileges to harvested metadata.
