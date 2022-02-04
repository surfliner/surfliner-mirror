# Tidewater

## Development Environment

You will need Docker and Docker Compose installed on your host/local system.

To setup a development environment:
1. `docker-compose build` to build images (`docker-compose up --build` does not work)
1. `docker-compose up`  to run dev environment
1. `docker-compose --profile queue up` to run dev environment with RabbitMQ service
   (this is optional and will not always be desirable or necessary)
1. Access the application on http://localhost:3000

See the `docker-compose` [CLI reference][cli-reference] for more on commands.

[cli-reference]: https://docs.docker.com/compose/reference/overview/

## Documentation

See [the Tidewater chapter of the Surfliner manual][tidewater-manual].

[tidewater-manual]: ../docs/themanual/tidewater/
