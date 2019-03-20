Lark Client
===========

This is a Ruby client for the [Lark][lark] server API.

## Development

In development, it's helpful to have a Lark server running. See the
[Lark README.md][lark-readme] for more information. You can do this by running
the server directly with Rack:

```sh
  cd ../lark; bundle exec rackup config.ru
```

You can also run with docker using:

```sh
  ../lark/bin/docker-build.sh`
  ../lark/bin/docker-up.sh`
```

## License

Lark is made available under the [MIT License][license].

[lark]: ../lark
[lark-readme]: ../lark/README.md
[license]: ../LICENSE
