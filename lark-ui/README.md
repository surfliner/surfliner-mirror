# Lark UI

Provides a web interface for [Lark][lark] using [Rails][rails].

## Developing locally

You will need Docker and Docker Compose installed on your host/local system.

To setup a development environment:
1. `docker-compose build` to build images (`docker-compose up --build` does not work)
1. `docker-compose up`  to run dev environment
1. Access the application on http://localhost:3000

[lark]: ../lark/README.md
[rails]: https://rubyonrails.org/
