# Tidewater

Please see [CONTRIBUTING.md][contributing] for information about contributing to
this project. By participating, you agree to abide by the
[UC Principles of Community][principles].

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

### Tidewater Consumer script

Tidewater Consumer script consumes Comet data like OaiSet, OaiItem, and OaiEntry to the consumer. The script listens on a RabbitmMQ topic and routing key for messages from Comet.  It uses the payload resourceUrl to get the data. ResourceUrl is expected to be a URL to superskunk API for accessing the data itself. It is intended to be independent from the Rails application.  It could be extracted into it's own project if needed.

See [Tidewater Consumer script][helm-chart-tidewater] for more information regarding configuration and how it is deployed. 

[contributing]: ../CONTRIBUTING.md
[principles]: https://ucnet.universityofcalifornia.edu/working-at-uc/our-values/principles-of-community.html
[tidewater-manual]: ../docs/themanual/tidewater/
[helm-chart-tidewater]: ../charts/tidewater#tidewater-consumer