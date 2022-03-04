# Lark UI

Please see [CONTRIBUTING.md][contributing] for information about contributing to
this project. By participating, you agree to abide by the
[UC Principles of Community][principles].

Provides a web interface for [Lark][lark] using [Rails][rails].

## Developing locally

You will need Docker and Docker Compose installed on your host/local system.

To setup a development environment:
1. `docker-compose build` to build images (`docker-compose up --build` does not work)
1. `docker-compose up`  to run dev environment
1. Access the application on http://localhost:3000

You can run `RSpec` tests with:

```sh
docker-compose exec web sh -c 'bundle exec rspec'
```

[contributing]: ../CONTRIBUTING.md
[lark]: ../lark/README.md
[principles]: https://ucnet.universityofcalifornia.edu/working-at-uc/our-values/principles-of-community.html
[rails]: https://rubyonrails.org/
