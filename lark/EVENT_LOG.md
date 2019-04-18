# The Lark Event Log

Lark's state is maintained by a single append-only event log. The event log
serves as a canonical data source for authority records. This document
provides the abstract specification for that log, as well as some notes about
its implementation.

Every change to the state of Lark is encapsulated in an event object and
stored sequentially. In principle, the full internal state of the application and
its records can be reconstructed from the events on the log.

## Events

_Events_ are simple data structures holding:

  - `type`: a token representing specifying the semantics of the event data.
  - `data`: a key-value structure providing the event details.
  - `date_created`: a *unique* timestamp.

> _Implementation Note_:
>
> Events are implemented as `Valkyrie::Resource` objects. This means they use
> [`dry-schema`][dry-schema] and [`dry-types`][dry-types].

## Event Types

Each _Event_ has a `type`, corresponding to semantics for its `data`. This
section defines types that appear in the log, and specifies the expected data
and their impact on the application and record states.

_Events_ missing required (__MUST__) data __MUST__ be ignored (i.e. treated as a
no-op); additionally __SHOULD__ be rejected when added to the log.

For example: a `:create` *Event* without an `id` **SHOULD** result in an error
when added to the log. If such an event is encountered when reading the log, it
__MUST NOT__ result in the creation of any record (or in any other change to
application/record state).

### Create

A `:create` _Event_ establishes the existence of a particular _Authority
Record_.

__Data__:

`:create` _Events_ __MUST__ have an `id`. The value of this attribute is a
string identifier for the created record.

| Key       | Requirement |                             Description                              |
|-----------|-------------|----------------------------------------------------------------------|
| `id`      | __MUST__    | The identifier of the record created by the event.                   |

### Change Properties

A `:change_property` _Event_ updates the properties of an _Authority
Record_.

__Data__:

| Key       | Requirement |                             Description                              |
|-----------|-------------|----------------------------------------------------------------------|
| `id`      | __MUST__    | The identifier of the record to which changes are applied.           |
| `changes` | __MUST__    | A data structure containing the changes to be applied to the record. |

[dry-schema]: https://dry-rb.org/gems/dry-schema/
[dry-types]: https://dry-rb.org/gems/dry-types/

## The Event Log

The _EventStream_ is a totally-ordered and persistent stream of _Events_. The log
is _append only_, meaning events can only be added (never destroyed), and each
event is added to the end of the log (i.e. after the previous event).

The log is primarily for internal use, though aspects of it __MAY__ be exposed
via the API, especially for expressing record history/provenance.

_Events_ added to the log are published to listeners/subscribers.

## The Event Stream

Lark implements a [dry-events](https://dry-rb.org/gems/dry-events/) publisher/subscriber
API to define the flow for event logging. This allows for the creation of event publishers
and a convenient way to subscribe/listen to the events.

Each time a valid request to resolve authority records is received through the `RecordController`
or `BatchController`, an `Event` gets generated and appended into the `EventStream`
in a sequential manner.

Lark's system-wide events are tracked by the `EventStream`. This is a `Singleton`, meaning
there is exactly one `.instance` and `EventStream.new` is private.

For example:
An event can be created by doing
```
  event = Event.new(type: :create, data: { id: id })
```

An event can be added to the log by doing
```
  Lark.config.event_stream << event
```

Whenever an event is persisted to the `EventStream`, it should also also get published.
The `Dry::Events::Publisher` implementation can be found in the `Lark::EventStream::Publisher` class.

```
  def publish_event(event)
    publish('created', event.data)
  end
```

An event listener _IndexListener_ listens for events on the _EventStream_. The `IndexListener`
class subscribes to the stream through a config in `lark/config/environment.rb`.

```
  Lark.config.event_stream.subscribe(IndexListener.new)
```

The _IndexListener_ class implements methods based on the _Event's_ `types` while following
convention laid down by `Dry::Events`and in turn handles updates to the index as needed.

```
  class IndexListener
    def on_created(event)
      indexer.index(data: Concept.new(event.payload))
    end
  end
```
