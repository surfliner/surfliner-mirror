# Ingesting objects into Shoreline

The rake task for ingesting data into shoreline takes zipped shapefiles and
sends them to both GeoServer and GeoBlacklight:

```sh
export SHORELINE_PROVENANCE='Your Institution'
export SHORELINE_ACCESS=Public

bin/rake shoreline:publish[spec/fixtures/shapefiles/gford-20140000-010002_lakes.zip]

# or for multiple at once
for zip in spec/fixtures/shapefiles/*.zip; do
  bin/rake shoreline:publish[${zip}]
done
```

If you need to remove an ingested item, you can delete it from solr with
`solrconf:delete_by_ids`:

```sh
export SOLR_DELETE_IDS=FY2015_ADDRESS_POINT,citiescounty_021616
bin/rake solrconf:delete_by_ids
```

The shapefile will remain in GeoServer, however; you can delete it from there
via the GeoServer admin UI.
