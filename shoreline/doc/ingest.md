# Ingesting objects into Shoreline

The rake task for ingesting data into shoreline takes a CSV and ingests the
specified objects into both GeoServer and GeoBlacklight:

```sh
SHORELINE_FILE_ROOT=$(pwd)/spec/fixtures/shapefiles bundle exec rake shoreline:ingest[spec/fixtures/csv/Metadata_Extract.csv]
```

If you need to remove an ingested item, you can delete it from solr with
`shoreline:delete_by_ids`:

```sh
export SOLR_DELETE_IDS=FY2015_ADDRESS_POINT,citiescounty_021616
bin/rake shoreline:delete_by_ids
```

The shapefile will remain in GeoServer, however; you can delete it from there
via the GeoServer admin UI.
