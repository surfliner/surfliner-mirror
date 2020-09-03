<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Shoreline Discovery](#shoreline-discovery)
    - [Local Development](#local-development)
    - [Deployment](doc/deploy.md)
    - [Ingesting objects](doc/ingest.md)

<!-- markdown-toc end -->
# Shoreline Discovery

Shorline Discovery is a [GeoBlacklight][geoblacklight] frontend for the Shoreline
geospatial system.

Please see [CONTRIBUTING.md][contributing] for information about contributing to
this project. By participating, you agree to abide by the
[UC Principles of Community][principles].

## Local Development

Checkout the `surfliner` repository with and `cd` into the `shoreline/discovery`
directory.

```sh
git clone git@gitlab.com:surfliner/surfliner.git
cd surfliner/shoreline/discovery
```

The development environment is supported with Docker Compose. To run the
dockerized environment, you will need Docker and Docker Compose installed on
your local system.

To setup a development environment:
1. `docker-compose up --build` to build images (if necessary)
1. `docker-compose up`  to run dev environment
1. Access the `discovery` application on [`http://localhost:3000`][localhost].

For running tests:
```
docker-compose exec app bundle exec rspec
```

See the [`docker-compose` CLI
reference](https://docs.docker.com/compose/reference/overview/) for more on commands.

## [Deployment](doc/deploy.md)

## [Ingesting objects](doc/ingest.md)

[contributing]: ../../CONTRIBUTING.md
[geoblacklight]: https://github.com/geoblacklight/geoblacklight
[localhost]: http://localhost:3000
[principles]: https://ucnet.universityofcalifornia.edu/working-at-uc/our-values/principles-of-community.html
[rails]: https://rubyonrails.org/
[solr]: http://lucene.apache.org/solr/
