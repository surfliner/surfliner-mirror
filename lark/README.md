# Lark

Lark is an authority control platform and API. It is a product of the
[Surfliner](https://gitlab.com/surfliner/surfliner) collaboration at the
University of California.

Please see [CONTRIBUTING.md][contributing] for information about contributing to
this project. By participating, you agree to abide by the
[UC Principles of Community][principles].

Please see [surfliner Documentation Website](https://surfliner.gitlab.io/docs/docs/home/) for more information.

## Data Model

### Concept

### Event Log

## API

Lark supports a REST API for managing and consuming authority records.

A description of the API service is available from the running application via a `GET` request on the application root (`curl http://localhost:9292/`).

### Retrieve (HTTP GET)

Retrieve the content of an authority record with a matching id

```sh
curl -H "Accept: application/json" http://localhost:9292/3f707b6e-2589-476c-9d5c-ce39bec637f6
```

Response

```sh
Status: 200 OK

Body:
{"pref_label":["test"],"alternate_label":[],"hidden_label":[],"exact_match":[],"close_match":[],"note":[],"scope_note":[],"editorial_note":[],"history_note":[],"definition":[],"scheme":"http://www.w3.org/2004/02/skos/core#ConceptScheme","literal_form":[],"label_source":[],"campus":[],"annotation":[],"id":"3f707b6e-2589-476c-9d5c-ce39bec637f6"}
```

#### Error Case

Retrieve the content of an authority record with no matching id

```sh
curl -H "Accept: application/json" http://localhost:9292/fake-id
```

Response

```sh
Status: 404 Not Found

Body: Valkyrie::Persistence::ObjectNotFoundError
```

#### Status

`200` OK

`404` Not Found

Please see [Data Model](#data-model) and
[List of Supported Media Types](#supported-media-types) section for more information.

### Create (HTTP POST)

Create a new authority record

```sh
curl -v --data '{"pref_label":"moomin"}' -H "Content-Type: application/json" http://localhost:9292/
```

Response

```sh
Status: 201 Created

Headers:
Content-Type: application/json
Content-Length: 347
X-Content-Type-Options: nosniff

Body:
{"pref_label":["moomin"],"alternate_label":[],"hidden_label":[],"exact_match":[],"close_match":[],"note":[],"scope_note":[],"editorial_note":[],"history_note":[],"definition":[],"scheme":"http://www.w3.org/2004/02/skos/core#ConceptScheme","literal_form":[],"label_source":[],"campus":[],"annotation":[],"id":"537ebbd2-b3f8-433f-91e8-494d8a0e927a"}
```

#### Error Cases

Create an unsupported format authority record

```sh
curl -v --data '{"pref_label":"moomin"}' -H "Content-Type: application/fake" http://localhost:9292/
```

Response

```sh
Status: 415 Unsupported Media Type

Headers:
Content-Type: text/html;charset=utf-8
Content-Length: 16
X-Content-Type-Options: nosniff
```

Create a malformed JSON authority record

```sh
curl -v --data "malformed json" -H "Content-Type: application/json" http://localhost:9292/
```

Response

```sh
Status: 400 Bad Request

Headers:
Content-Type: text/html;charset=utf-8
Content-Length: 41
X-Content-Type-Options: nosniff
```

#### Status

`201` Created

`400` Bad Request

`415` Unsupported Media Type

Please see [Data Model](#data-model) and
[List of Supported Media Types](#supported-media-types) section for more information.

### Update (HTTP PUT)

Update an existing authority record.

Create an authority record
```sh
curl -i -XPOST --data '{"pref_label":"moomin"}' -H "Content-Type: application/json" http://localhost:9292/
```

Update the authority with the ID of the record created
```sh
curl -i -XPUT --data '{"pref_label":"moomin updated"}' -H "Content-Type: application/json" http://localhost:9292/c7be4834-929e-43b6-a418-a708f3eceade
```

Response
```
HTTP/1.1 200 OK
Content-Type: application/json
...

Body:
{"pref_label":["moomin updated"],"alternate_label":[],"hidden_label":[],"exact_match":[],"close_match":[],"note":[],"scope_note":[],"editorial_note":[],"history_note":[],"definition":[],"scheme":"http://www.w3.org/2004/02/skos/core#ConceptScheme","literal_form":[],"label_source":[],"campus":[],"annotation":[],"id":"c7be4834-929e-43b6-a418-a708f3eceade"}

```

#### Error Cases

##### With non-existing authority record
```sh
$ curl -i -XPUT --data '{"pref_label":"moomin updated"}' -H "Content-Type: application/json" http://localhost:9292/a_fake_id
```

Response
```
HTTP/1.1 404 Not Found
Content-Type: text/html;charset=utf-8
Content-Length: 42

Valkyrie::Persistence::ObjectNotFoundError
```

##### With unsupported format

```sh
curl -i -XPUT --data '{"pref_label":"moomin updated"}' -H "Content-Type: application/fake" http://localhost:9292/c7be4834-929e-43b6-a418-a708f3eceade
```

```
HTTP/1.1 415 Unsupported Media Type
Content-Type: text/html;charset=utf-8
Content-Length: 16

```

##### With malformed data

```sh
curl -i -XPUT --data 'some data' -H "Content-Type: application/json" http://localhost:9292/c7be4834-929e-43b6-a418-a708f3eceade
```

Response

```
HTTP/1.1 400 Bad Request
Content-Type: text/html;charset=utf-8
Content-Length: 36

767: unexpected token at 'some data'
```

#### Status

`200` OK

`400` Bad Request

`404` Not Found

`415` Unsupported Media Type

### Batch Update (HTTP POST)

Update authority records in batch.

```sh
curl -i -XPOST --data '[{"pref_label":"moomin updated", "id":"8e3e04fc-24c7-4ee2-b381-c4229b54ca2f"}, {"pref_label":"PrefLabel updated", "id":"b27415f4-0fdc-433e-a9f5-91fd1448880a"}]' -H "Content-Type: application/json" http://localhost:9292/batch_edit
```

Response
```
HTTP/1.1 204 No Content

```

#### Error Cases

##### With non-existing authority record
```sh
$ curl -i -XPOST --data '[{"pref_label":"moomin updated", "id":"a_fake_id"}]' -H "Content-Type: application/json" http://localhost:9292/batch_edit
```

Response
```
HTTP/1.1 404 Not Found
Content-Type: text/html;charset=utf-8
Content-Length: 42

Valkyrie::Persistence::ObjectNotFoundError
```

##### With unsupported format
```sh
curl -i -XPOST --data '[{"pref_label":"moomin updated", "id":"8e3e04fc-24c7-4ee2-b381-c4229b54ca2f"}]' -H "Content-Type: application/fake" http://localhost:9292/batch_edit
```

```
HTTP/1.1 415 Unsupported Media Type
Content-Type: text/html;charset=utf-8
Content-Length: 16

```

##### With malformed data

```sh
curl -i -XPOST --data 'some data' -H "Content-Type: application/json" http://localhost:9292/batch_edit
```

Response

```
HTTP/1.1 400 Bad Request
Content-Type: text/html;charset=utf-8
Content-Length: 35

767: unexpected token at 'any data'
```

### Batch Import CSV (HTTP POST)
The documentation for CSV batch import, including supported header/column format, is given at [CSV_IMPORT.md][csv-import].

### Basic Term Search (HTTP GET /search)
Retrieve authority records that match the basic term pref-label or alternate-label (exact matching).

```sh
$ curl -i http://localhost:9292/search?pref_label=A+label
```

Response
```
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 361
...

[{ "pref_label":["A label"],"alternate_label":[],"hidden_label":[],"exact_match":[], ...}]
```

#### No Results

```sh
$ curl -i http://localhost:9292/search?pref_label=any+label
```

Response
```
HTTP/1.1 404 Not Found
Content-Type: text/html;charset=utf-8
Content-Length: 0

```

#### Status

`200` OK

`404` Not Found


### Supported Media Types

Lark aims to support a variety of media types.

Currently we support:

| Format |       CType        |                      Documentation                     |
|--------|--------------------|--------------------------------------------------------|
| JSON   | `application/json` | Key/value string representing of the authority record. |

### Serializers

#### JSON Serializer
All attributes present in the mode, as well as ID, will be serialized in order, while those internal attributes added by Valkyrie will be ignored.

A. Concept
```
  JSON Output:
   { "pref_label": ["..."],
     "alternate_label": [],
     "hidden_label": [],
     "exact_match": [],
     "close_match": [],
     "note": [],
     "scope_note": [],
     "editorial_note": [],
     "history_note": [],
     "definition": [],
     "scheme": "http://www.w3.org/2004/02/skos/core#ConceptScheme",
     "literal_form": [],
     "label_source": [],
     "campus": [],
     "annotation": [],
     "id": "..." }
```

## Development

Checkout the `surfliner` repository with and `cd` into the `lark` product
directory.

```sh
git clone git@gitlab.com:surfliner/surfliner.git
cd surfliner/lark
```

### Dependencies

#### Prerequisites

Lark requires to install the following softwares:

1. [`Solr`][solr] version >= 5.x
1. [`PostgreSQL`][postgres]

#### Minting ARKs with EZID

By default, Lark will mint identifiers for records using a `SecureRandom.uuid`

If you would like to use an EZID service, you will need to ensure the following
environment variables are provided to the application.

- `MINTER` set to `"ezid"`
- `EZID_DEFAULT_SHOULDER` set to your EZID service shoulder. Example: `"ark:/99999/fk4"`
- `EZID_USER` set to your EZID account username: Example: `"apitest"`
- `EZID_PASSWORD` set to your EZID account password: Example: `"my-ezid-password"`

#### Gems

To install the Ruby dependencies for the project, do:

```sh
bundle install
```
[racksh](https://github.com/sickill/racksh) is a console for Rack based ruby web applications.
We use it to load Lark's environment for Sinatra. It loads Lark's environment like a Rack web server,
but instead of running the app it starts an irb session. Additionally, it exposes $rack variable
which allows us to make simulated HTTP requests to our app.

#### Database

To initialize the [`PostgreSQL`][postgres] database for Event Log, run:

```sh
rake db:create (first time only)

rake db:migrate
```

#### Import Dummy Records

Make sure docker is up and running in development

```sh
docker exec dev_web_1 rake lark:seed
```

#### Re-indexing

To re-index a single record with :id
```
$ rake reindex[':id']
```

To re-index all authority records from persisted event data
```
$ rake reindex_all
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

### Running with Docker
You will need Docker and Docker Compose installed on your host/local system.

To setup a development environment:
1. `docker-compose up --build` to build images (if necessary)
1. `docker-compose up`  to run dev environment
1. Access the `lark` API on `http://localhost:5000`

For running tests:
```
docker-compose exec web bundle exec rspec
```

See the [`docker-compose` CLI
reference](https://docs.docker.com/compose/reference/overview/) for more on commands.

### Running the Test Suite

We maintain robust unit and integration tests. The full test suite currently
runs in a fraction of a second. We recommend running it frequently during
development.

If you have a properly configured [Solr index][#index] and [PostgreSQL][postgres]
for [Event Log][#Event Log], you can run the entire test suite with:

```sh
$ bundle exec rspec
```

If you want to avoid setting up a Solr and PostgreSQL backend, you can run the test suite
using in-memory data stores, do:

```sh
$ INDEX_ADAPTER=memory EVENT_ADAPTER=memory bundle exec rspec
```

### Architecture

#### Index

Lark requires an index to back its API's read and search functionality. We
communicate to this index using a Ruby data mapper library called
[`Valkyrie`][valkyrie]. This means that backend for the index is swappable;
presently, it supports [Apache Solr][solr] and an in-memory only backend
useful mainly for unit testing.

Solr runs as a docker service in the development and test environments. The
valkyrie `solr` adapter is in use as the Lark index_adapter. The
index can be selected before startup by setting the `INDEX_ADAPTER` env
variable (choose `solr` or `memory`).

For non-trivial development tasks, it's advisable to setup and configure Solr
in the development environment. The easiest way to do this is to use the
included Docker Compose configuration; see [Running with Docker][#running-with-docker].
If you want to run Solr directly on your local system, you'll need to setup a
core with the configuration in `lark/solr/config` and point Lark to it by setting
the `SOLR_URL` env variable.

ENV-driven configuration options are introduced through
[dotenv](https://github.com/bkeepers/dotenv) for non-production environments.

#### Event Log

Lark tracks all state-changing activity in an append-only event log. Most
application behavior is triggered by listeners observing this log via
[`dry-events`][dry-events].

The storage backend for Event Log is [`PostgreSQL`][postgres]. The  valkyrie `postgres` adapter
 is configured for Lark event_adapter. But it can store in memory by setting the `EVENT_ADAPTER`
env variable (choose `sql` or `memory`) before startup.

For non-trivial development tasks, it's advisable to setup and configure Postgres
in the development environment. The easiest way to do this is to use the included Docker Compose
configuration; see [Running with Docker][#running-with-docker].

If you want to run Postgres directly on your local system, you'll need to setup Postgres
and point Lark to it by setting env variable `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`,
and `POSTGRES_HOST`.

The specification for this log, including details about event types and their
semantics, is given in [`EVENT_LOG.md`][event-log]

## Production Considerations

### Deployment

We maintain resources for deploying Lark with Docker, Helm and Kubernetes. Documentation for those
resources is at [DEPLOYMENT.md][delpoyment].

### Monitoring

Lark provides a [health check endpoint][rack-healthcheck] at `/healthz/complete`.

## License

Lark is made available under the [MIT License][license].


[contributing]: ../CONTRIBUTING.md
[principles]: https://ucnet.universityofcalifornia.edu/working-at-uc/our-values/principles-of-community.html
[solr]: http://lucene.apache.org/solr/
[postgres]: https://www.postgresql.org/
[valkyrie]: https://github.com/samvera-labs/valkyrie
[rack]: https://rack.github.io/
[webrick]: https://ruby-doc.org/stdlib-2.5.0/libdoc/webrick/rdoc/WEBrick.html
[dry-events]: https://dry-rb.org/gems/dry-events/
[event-log]: ./EVENT_LOG.md
[deployment]: ./DEPLOYMENT.md
[rack-healthcheck]: https://github.com/downgba/rack-healthcheck
[license]: ../LICENSE
[csv-import]: ./CSV_IMPORT.md
