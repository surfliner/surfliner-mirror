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

[docker]: https://docs.docker.com/engine/install/
[compose]: https://docs.docker.com/compose/
[compose-install]: https://docs.docker.com/compose/install/
[hyrax]: https://hyrax.samvera.org/
[rspec]: https://rspec.info/
[rspec-cli]: https://relishapp.com/rspec/rspec-core/docs/command-line
[samvera]: https://samvera.org/
