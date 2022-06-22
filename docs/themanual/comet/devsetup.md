## Setting up a development environment for Comet

Comet's web service is a Rails application written using the [`hyrax`][hyrax]
engine provided by the [Samvera Community][samvera].

The current practice for Comet development is to use [`docker-compose`][compose]
which configures multi-container applications in your local development context.

You will need the following tools installed on your local machine:

* [Docker Engine][docker]
* [docker-compose][compose-install]

### Dependency installation for Mac and Windows

For both environments, you need to install Docker Desktop.

**Mac** https://docs.docker.com/docker-for-mac/install/
**Windows** https://docs.docker.com/docker-for-windows/install/

In both cases, the Docker Desktop installation includes `docker-compose`.

## Running the environment

If you don't already have a local development copy of this repository, check it
out and move to the `comet` project directory:

```sh
git clone https://gitlab.com/surfliner/surfliner.git
cd surfliner/comet
```

Build the comet images with `docker-compose build`, and run the environment with
`docker-compose up`. Either of these steps may take some time the first time
through as build processes run and images download. You should benefit from
caching on subsequent runs.

You should now have a running version of the web application at
https://localhost:3000.

Other applicaiton components are available as services mapped to other localhost
ports, to see a list do `docker-compose ps`. These services are the components
necessary to run the application in a production-like environment (databases,
caches, message queues, etc...), as well as those that are useful for the test
environment (e.g. a chrome browser engine). All the services are configured by
[`.env`](../../../comet/.env); if you're looking for access credentials or
other configuration details, the environment variables there will likely be
your answer.

The application itself is loaded with seed data from
[`db/seeds.rb`](../../../comet/db/seeds.rb).

### Workaround for M1 Macs

At time of writing, Bitnami (who we use for our Docker images)
[does not officially support ARM64 architectures][bitnami/charts#7305]. This is
not generally a problem, as the Intel emulation provided by Docker Desktop
*usually* works without issue. Unfortunately, there is one exception: RabbitMQ.

If you try to run `docker-compose up` on an M1 Mac, the `rabbitmq` container
will likely fail with mysterious errors:

    rabbitmq 19:57:06.26
    rabbitmq 19:57:06.29 Welcome to the Bitnami rabbitmq container
    rabbitmq 19:57:06.31 Subscribe to project updates by watching https://github.com/bitnami/bitnami-docker-rabbitmq
    rabbitmq 19:57:06.33 Submit issues and feature requests at https://github.com/bitnami/bitnami-docker-rabbitmq/issues
    rabbitmq 19:57:06.36
    rabbitmq 19:57:06.38 INFO  ==> ** Starting RabbitMQ setup **
    rabbitmq 19:57:06.56 INFO  ==> Validating settings in RABBITMQ_* env vars..
    rabbitmq 19:57:06.89 INFO  ==> Initializing RabbitMQ...
    rabbitmq 19:57:07.23 INFO  ==> Generating random cookie
    rabbitmq 19:57:07.57 INFO  ==> Starting RabbitMQ in background...
    /opt/bitnami/scripts/libos.sh: line 336:   148 Segmentation fault      "$@" > /dev/null 2>&1
    /opt/bitnami/scripts/libos.sh: line 336:   244 Segmentation fault      "$@" > /dev/null 2>&1
    /opt/bitnami/scripts/libos.sh: line 336:   291 Segmentation fault      "$@" > /dev/null 2>&1
    /opt/bitnami/scripts/libos.sh: line 336:   338 Segmentation fault      "$@" > /dev/null 2>&1
    /opt/bitnami/scripts/libos.sh: line 336:   385 Segmentation fault      "$@" > /dev/null 2>&1
    /opt/bitnami/scripts/libos.sh: line 336:   432 Segmentation fault      "$@" > /dev/null 2>&1
    /opt/bitnami/scripts/libos.sh: line 336:   479 Segmentation fault      "$@" > /dev/null 2>&1
    /opt/bitnami/scripts/libos.sh: line 336:   526 Segmentation fault      "$@" > /dev/null 2>&1
    /opt/bitnami/scripts/libos.sh: line 336:   573 Segmentation fault      "$@" > /dev/null 2>&1
    /opt/bitnami/scripts/libos.sh: line 336:   620 Segmentation fault      "$@" > /dev/null 2>&1
    rabbitmq 19:58:53.24 ERROR ==> Couldn't start RabbitMQ in background.

This is due to [a bug in QEMU][docker/for-mac#5123] (which Docker Desktop uses
to emulate amd64 on M1 Macs). There is no resolution. The good news is that
RabbitMQ is mostly unnecessary in development environments (it is only useful if
you are testing integrations pertaining to object publishing), and it can be
safely dropped from your (local) `docker-compose.yml` as follows:

1. In `docker-compose.yml`, for both the `web` and `sidekiq` services:

    1. Add the following:

        ```yaml
        environment:
        - RABBITMQ_ENABLED=false
        ```

    1. In `command`, replace

        ```yaml
        - >
          if ./scripts/rabbitmq-wait; then
            ❲wrapped-command❳
          fi
        ```

        with `- ❲wrapped-command❳`.

    1. Remove `- rabbitmq` from `depends_on`.

1. Finally, delete the `rabbitmq` service in its entirety.

This should allow you to bring up Comet with `docker-compose up` as expected.

### Running the test suite

The `comet` test suite is written with [`RSpec`][rspec], which provides a
flexible [command line interface][rspec-cli] for running the parts of a test
suite you are interested in. You can access this CLI by using
`docker-compose exec web [command]` to access run the commands in the
`comet-web` container. In the simplest case, to run the whole test suite:

```sh
docker-compose exec web bundle exec rspec
```

> Note: currently some of these tests seem to fail on a local docker
> environment. Please communicate about failing tests in your environment
> via Slack. Efforts to fix this are highly valued, but if you need to
> move forward with your ticket you can consider the CI/CD pipeline the
> canonical environment for the test suite. If your work passes there,
> it can be cleared for merge.

[bitnami/charts#7305]: https://github.com/bitnami/charts/issues/7305
[compose]: https://docs.docker.com/compose/
[compose-install]: https://docs.docker.com/compose/install/
[docker]: https://docs.docker.com/engine/install/
[docker/for-mac#5123]: https://github.com/docker/for-mac/issues/5123
[hyrax]: https://hyrax.samvera.org/
[rspec]: https://rspec.info/
[rspec-cli]: https://relishapp.com/rspec/rspec-core/docs/command-line
[samvera]: https://samvera.org/
