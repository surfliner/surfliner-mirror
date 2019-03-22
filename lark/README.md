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
HTTP/1.1 204 No Content

```

#### Error Cases

##### With non-existing authority record
```sh
$ curl -i -XPUT --data '{"pref_label":"moomin updated"}' -H "Content-Type: application/json" http://localhost:9292/a_fade_id
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

`204` Created

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
$ curl -i -XPOST --data '[{"pref_label":"moomin updated", "id":"a_fade_id"}]' -H "Content-Type: application/json" http://localhost:9292/batch_edit
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

#### Gems

To install the Ruby dependencies for the project, do:

```sh
bundle install
```

#### Index

Lark requires an index to back its API's read and search functionality. We
communicate to this index using a Ruby data mapper library called
[`Valkyrie`][valkyrie]. This means that backend for the index is swappable;
presently, it supports [Apache Solr][solr] and an in-memory only backend
useful mainly for unit testing.

The index can be selected before startup by setting the `INDEX_ADAPTER` env
variable (choose `solr` or `memory`).

For non-trivial development tasks, it's advisable to setup and configure Solr
in the development environment. The easiest way to do this is to use the
included Docker Compose configuration; see [Running with Docker][#running-with-docker].
If you want to run Solr directly on your local system, you'll need to setup a
core with the configuration in `solr/config` and point Lark to it by setting
the `SOLR_URL` env variable.

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

There are two docker-compose files, which allow you to run development and test
instances of the application if you would like.

To setup a development environment:
1. `./bin/docker-build.sh`  to build images
1. `./bin/docker-up.sh`  to run dev environment
1. Access the `lark` API on `http://localhost:5000`

For running tests:
1. `./bin/docker-build.sh -e test`  to build images
1. `./bin/docker-up.sh -e test`  to run test environment
1. `./bin/docker-spec.sh -e test` to run test suite

### Running the Test Suite

We maintain robust unit and integration tests. The full test suite currently
runs in a fraction of a second. We recommend running it frequently during
development.

If you have a properly [configured Solr index][#index], you can run the
entire test suite with:

```sh
$ bundle exec rspec
```

If you want to avoid setting up a Solr backend, you can run the test suite
using in-memory data stores, do:

```sh
$ INDEX_ADAPTER=memory bundle exec rspec
```

### Architecture

#### Event Log

Lark tracks all state-changing activity in an append-only event log. Most
application behavior is triggered by listeners observing this log via
[`dry-events`][dry-events].

The specification for this log, including details about event types and their
semantics, is given in [`EVENT_LOG.md`][event-log]

## License

Lark is made available under the [MIT License][license].


[contributing]: ../CONTRIBUTING.md
[principles]: https://ucnet.universityofcalifornia.edu/working-at-uc/our-values/principles-of-community.html
[solr]: http://lucene.apache.org/solr/
[valkyrie]: https://github.com/samvera-labs/valkyrie
[rack]: https://rack.github.io/
[webrick]: https://ruby-doc.org/stdlib-2.5.0/libdoc/webrick/rdoc/WEBrick.html
[dry-events]: https://dry-rb.org/gems/dry-events/
[event-log]: ./EVENT_LOG.md
[license]: ../LICENSE
