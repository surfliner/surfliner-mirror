# Shoreline Discovery

Shorline Discovery is a [GeoBlacklight][geoblacklight] frontend for the Shoreline
geospatial system.

Please see [CONTRIBUTING.md][contributing] for information about contributing to
this project. By participating, you agree to abide by the
[UC Principles of Community][principles].


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

 is a [Rails][rails] application. To start the server you can run


```sh
bundle exec rails server
```

After this, the application should be available on
[`http://localhost:3000`][localhost].

### Running with Docker

The development environment is supported with Docker Compose. To run the
dockerized environment, you will need Docker and Docker Compose installed on
your local system.

To setup a development environment:

1. `docker-compose -f docker/dev/docker_compose.yml build` to build the images
1. `docker-compose -f docker/dev/docker_compose.yml up` to run the development
   environment.
1. Access the `discovery` application on [`http://localhost:3000`][localhost].

[contributing]: ../../CONTRIBUTING.md
[geoblacklight]: https://github.com/geoblacklight/geoblacklight
[localhost]: http://localhost:3000
[principles]: https://ucnet.universityofcalifornia.edu/working-at-uc/our-values/principles-of-community.html
[rails]: https://rubyonrails.org/
[solr]: http://lucene.apache.org/solr/
