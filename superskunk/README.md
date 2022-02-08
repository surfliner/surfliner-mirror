# superskunk

superskunk is the metadata API for [`comet`](../comet).

## The API

`GET /objects/{id}`

### JSON‐LD Profile Negotiation

The content of JSON‐LD API responses varies depending on the requested *profile*.
Profiles can be specified as media type parameters on JSON‐LD media types, like so:

    application/ld+json; profile="example:profile"

Use the HTTP `Accept` header to make profile requests.
Supported profiles are documented [here](../docs/themanual/superskunk/profiles/).

## Development

Start it up on `localhost:3000` with:

```sh
docker-compose build
docker-compose up
```
