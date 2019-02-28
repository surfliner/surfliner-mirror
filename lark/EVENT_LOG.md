# The Lark Event Log

Lark's state is maintained by a single append-only event log. This document
provides the abstract specification for that log, as well as some notes about
its implementation.

In principle, the full internal state of the application and its records can be
reconstructed from the events on the log.

## Events

_Events_ are simple data structures holding:

  - `type`: a token representing specifying the semantics of the event data.
  - `data`: a key-value structure providing the event details.
  - `created_at`: a *unique* timestamp.

> _Implementation Note_:
>
> Events are implemented as `Valkyrie::Resource` objects. This means they use
> [`dry-schema`][dry-schema] and [`dry-types`][dry-types].

## The Log

The _Event Log_ is a totally-ordered and persistent stream of _Events_. The log
is _append only_, meaning events can only be added (never destroyed), and each
event is added to the end of the log (i.e. after the previous event).

The log is primarily for internal use, though aspects of it __MAY__ be exposed
via the API, especially for expressing record history/provenance.

_Events_ added to the log are published to listeners/subscribers.

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

`:create` _Events_ __MUST__ have an `id`. The value of this attribute is the
identifier for the created record.

`:create` events with an `id` corresponding to a record that already exists
__MUST__ be ignored.

### Change Property

%TK

[dry-schema]: https://dry-rb.org/gems/dry-schema/
[dry-types]: https://dry-rb.org/gems/dry-types/
