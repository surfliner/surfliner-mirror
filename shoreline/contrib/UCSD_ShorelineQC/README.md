# Shoreline IngestQC

## Primary goals:

1. Check field values for potential errors that might cause the ingest process to fail.
2. Attempt to ensure consistency from one ingest to another.

## Python Resources and libraries

* `pandas` - for tables and data structures
* `shapefile` - check if shapefile appears to be valid
* `pydantic` - check if license URL is a valid URL
* `config` - googlesheetID is in a separate file for security, this allows us to read it in
* `rich` - prettier printing
* `pathlib` - working with file paths

## External Resources

* Editable and shared Google sheet which allows updates to some of the fields checked
* Wikipedia for valid/standard language codes

## Checks in place to accomplish goals (as of `2022-07-26`)

* The root part of each file listed should be the same
* All files should have a date in the name
* Check ISO file:
  * There should be an ISO file listed
  * ISO should be in the file name
  * Extension should be `.xml`
* Check ZIP file:
  * Extension of file should be `.zip`
* Check the shapefile exists based on the filename of the zip file
* Check if the `format` listed is valid (based on a hard coded list)
* Check if the `access` listed is valid (based on a hard coded list)
  * Additionally check if `access` is capitalized
* Check if the `provenance` listed is valid (based on a hard coded list)
  * Apply a set of standardized rules to how the provenance should be formatted.
* Is the language code valid? Valid codes come from wikipedia(https://en.wikipedia.org/wiki/List_of_ISO_639-2_codes).
* Check if the `originator` listed is valid (based on valid publishers which comes from the `Google sheet`)
* Check if the `publisher` listed is valid (based on valid publishers which comes from the `Google sheet`)
* Check if the `collection` listed is valid (based on valid collections which comes from the `Google sheet`)
* Check if the `subject` listed is valid (based on valid topics which comes from the `Google sheet`)
* Check if the `spatialsubject` listed is valid (based on valid topics and valid places both of which comes from the `Google sheet`)
* Check if the `license` appears to be a valid URL

## ** Additional Notes **

Using pyinstaller to bundle all dependencies into an .exe so people 
don't need to install and maintain a python environment locally.

pyinstaller doesn't work with python 3.10 currently.

The venv for this folder is 3.9.9