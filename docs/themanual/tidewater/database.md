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

It is possible that an item might have multiple values for any given
  metadata term.
This can be represented in the database by catenating the values with
  a `U+FFFF` delimiter.
Note that `U+FFFF` would not otherwise be representable in OAI‐PMH data
  (it is invalid in XML); any `U+FFFF` which makes up part of a value
  **must** be replaced with `U+FFFD � REPLACEMENT CHARACTER` prior to
  its being stored in the database, to avoid its accidental
  interpretation as a value delimiter.
