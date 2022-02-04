# The Tidewater Database

## Configuration

See [<cite>Configuring Tidewater</cite>](./configuration.md).

## Items

Tidewater reads OAI‐PMH items from a table named `oai_items`.
In addition to the usual `id`, `created_at`, and `updated_at` columns
  commonly expected in Rails environments, Tidewater expects columns
  for each of the [Dublin Core 1.1 elements][dc11], such that, for
  example, the `identifier` column corresponds to `dc11:identifier`.
Databases should be Unicode, and columns should be `text`.

[dc11]: https://www.dublincore.org/specifications/dublin-core/dces/

The columns for metadata fields have the following format&#x202F;:—

    Value ::= Char*
    Language ::= Char*
    TaggedValue ::= Value (#xFFFE Language)?
    Field ::= TaggedValue (#xFFFF TaggedValue)*

Note that `U+FFFE` and `U+FFFF` would not otherwise be representable in
  OAI‐PMH data (they are invalid in XML); any `U+FFFE` or `U+FFFF`
  which makes up part of a value **must** be replaced with
  `U+FFFD � REPLACEMENT CHARACTER` prior to its being stored in the
  database, to avoid its accidental interpretation as a delimiter.

The Tidewater consumer script makes use of an additional column,
  `source_iri`, to identify items according to their identifiers in the
  API it consumes from.
The web app does not utilize this column for anything.
