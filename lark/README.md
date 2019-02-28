# Lark

Lark is an authority control platform and API. It is a product of the
[Surfliner](https://gitlab.com/surfliner/surfliner) collaboration at the
University of California.

Please see [CONTRIBUTING.md][contributing] for information about contributing to
this project. By participating, you agree to abide by the
[UC Principles of Community][principles].

## Data Model

%TK

## API

Lark supports a REST API for managing and consuming authority records.

### Retrieve (HTTP GET)

%TK

### Create (HTTP POST)

%TK

### Supported Media Types

Lark aims to support a variety of media types.

Currently we support:

| Format |       CType        | Documentation |
|--------|--------------------|---------------|
| JSON   | `application/json` | %TK           |

## Development

```sh
git clone git@gitlab.com:surfliner/surfliner.git
cd surfliner/lark

bundle install
```

### Starting Up

Lark is a [Rack][rack] application, and can be deployed with a variety of Ruby
web servers. To start Lark in development with [WEBrick][webrick], do:

```sh
$ rackup config.ru
```

Or run `shotgun` to start a server that automatically reloads code changes during development:

```sh
$ shotgun config.ru
```

### Running the Test Suite

We maintain robust unit and integration tests. The full test suite currently
runs in a fraction of a second. We recommend running it frequently during
development. It can be started with:

```sh
$ bundle exec rspec
```

## License

Lark is made available under the [MIT License][license].

[contributing]: ../CONTRIBUTING.md
[principles]: https://ucnet.universityofcalifornia.edu/working-at-uc/our-values/principles-of-community.html
[rack]: https://rack.github.io/
[webrick]: https://ruby-doc.org/stdlib-2.5.0/libdoc/webrick/rdoc/WEBrick.html
[license]: ../LICENSE
