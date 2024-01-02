# Local File System Harvesting {#localfilesystem_harvester}

This harvester will harvest metadata as XML files from a filesystem available on the machine running the GeoNetwork server.

## Adding a Local File System harvester

The figure above shows the options available:

- **Identification**:
    - *Name* - This is a short description of the filesystem harvester. It will be shown in the harvesting main page as the name for this instance of the Local Filesystem harvester.
    - *Group* - Group that owns the harvested metadata.
    - *User* - User that owns the harvested metadata.
- **Schedule** - Scheduling options. 
- **Configure connection to Directory**:  
    - *Directory* - The path name of the directory containing the metadata (as XML files) to be harvested.
    - *Also search in subfolders* - If checked and the *Directory* path contains other directories, then the harvester will traverse the entire file system tree in that directory and add all metadata files found.
    - *Script to run before harvesting*
    - *Type of record*
- **Configure response processing for filesystem**:
    - *Action on UUID collision* - Allows to configure the action when a harvester finds the same uuid on a record collected by another method (another harvester, importer, dashboard editor,...).
        - skipped (default)
        - overriden
        - generate a new UUID
- **Filtering and processing response** - Options that are applied to harvested content.
    - *Update catalog record only if file was updated*
    - *Keep local if deleted at source* - If checked then metadata records that have already been harvested will be kept even if they have been deleted from the *Directory* specified.
    - *Validate* - If checked, the metadata will be validated after retrieval. If the validation does not pass, the metadata will be skipped.
    - *Apply this XSLT to harvested records* - Choose an XSLT here that will convert harvested records to a different format.
    - *Batch edits*
      - *Category for harvested records* - The harvested metadata will be assigned to the selected category.

- **Privileges** - Assign privileges to harvested metadata.

!!! Notes

    -   in order to be successfully harvested, metadata records retrieved from the file system must match a metadata schema in the local GeoNetwork instance
