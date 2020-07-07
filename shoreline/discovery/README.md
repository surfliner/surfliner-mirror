# Shoreline Discovery

Shorline Discovery is a [GeoBlacklight][geoblacklight] frontend for the Shoreline
geospatial system.

Please see [CONTRIBUTING.md][contributing] for information about contributing to
this project. By participating, you agree to abide by the
[UC Principles of Community][principles].

## Ingesting objects

To ingest a shapefile into Shoreline, use the `shoreline:publish` Rake task (see
`doc/deploy.md` for information about the environment variables):
```
$ SHORELINE_PROVENANCE=“My institution” SHORELINE_ACCESS=Public bin/rake shoreline:publish[path/to/shapefile.zip]
```

The shapefile will be ingested into GeoServer and GeoBlacklight, and users can
download the shapefile and derivatives through the GeoBlacklight UI.

## Development

Checkout the `surfliner` repository with and `cd` into the `shoreline/discovery`
directory.

```sh
git clone git@gitlab.com:surfliner/surfliner.git
cd surfliner/shoreline/discovery
```

### Dependencies

#### Prerequisites

Shoreline Discovery requires running the following:

1. [`Solr`][solr]

#### Gems

To install the Ruby dependencies for the project, do:

```sh
bundle install
```

### Starting Up

The development environment is supported with Docker Compose. To run the
dockerized environment, you will need Docker and Docker Compose installed on
your local system.

To setup a development environment:

1. `bin/docker-build.sh` to build the images
1. `bin/docker-up.sh` to run the development
   environment.
1. Access the `discovery` application on [`http://localhost:3000`][localhost].

[contributing]: ../../CONTRIBUTING.md
[geoblacklight]: https://github.com/geoblacklight/geoblacklight
[localhost]: http://localhost:3000
[principles]: https://ucnet.universityofcalifornia.edu/working-at-uc/our-values/principles-of-community.html
[rails]: https://rubyonrails.org/
[solr]: http://lucene.apache.org/solr/
