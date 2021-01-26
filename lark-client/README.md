Lark Client
===========

This is a Ruby client for the [Lark][lark] server API.

## Development

In development, it's helpful to have a Lark server running. See the
[Lark README.md][lark-readme] for more information. You can do this by running
the server in docker with:

```sh
cd ../lark; docker-compose up --build
```

The `lark` API should then be available on http://localhost:5000.

## License

Lark is made available under the [MIT License][license].

[lark]: ../lark
[lark-readme]: ../lark/README.md
[license]: ../LICENSE
