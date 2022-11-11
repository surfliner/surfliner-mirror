# SurflinerSchema!Houndstooth

This document specifies the YAML format recognized by
`SurflinerSchema::Reader::Houndstooth` in the `surfliner_schema` gem. The intent
is for this format to be backwards‐compatible with [Samvera!Houndstooth][] while
innovating new features informed by practical concerns of the Surfliner project.

SurflinerSchema!Houndstooth is specified in prose by this document, and in code
by the `surfliner_schema` implementation. There is not (yet) a schema for
automated validation of conforming YAML files.

## General Structure

SurflinerSchema!Houndstooth files are YAML files representing a single top‐level
object with a number of properties. An `m3_version` property is **required**,
and **must** have a string value which starts with `"1.0"`.

> Ideally, there would be more sophisticated version processing than just
> `version.starts_with?("1.0")`, but at time of writing, this is what is
> supported.

All other properties are **optional**. The following properties are specified in
this document:

- `classes`
- `mappings`
- `properties`

> Samvera!Houndstooth also supports a `profile` property for describing the
> current schema, but it is currently ignored by `surfliner_schema`.
>
> The latest version (`1.0.beta2`) of Samvera!Houndstooth also adds a `contexts`
> property for annotating properties with the contexts in which they should
> appear. SurflinerSchema!Houndstooth is based on `1.0.beta1` and does not
> provide any context support.

## Keyed Lists

The `classes`, `mappings`, and `properties` properties are represented in
Samvera!Houndstooth as objects, with object keys supplying the internal “name”
for the associated value. For example:

```yaml
classes:
  generic_work:
    display_label: "Generic Work"
  collection:
    display_label: "Collection"
```

SurflinerSchema!Houndstooth allows the `name` property to declare the internal
name explicitly:

```yaml
classes:
  this_could_be_anything:
    name: "generic_work"
    display_label: "Generic Work"
  the_internal_name_is_still_collection:
    name: "collection"
    display_label: "Collection"
```

In this case, the values may be represented as a list instead of an object:

```yaml
classes:
  - name: "generic_work"
    display_label: "Generic Work"
  - name: "collection"
    display_label: "Collection"
```

Project Surfliner has found this final form to be useful for “extending”
existing generic properties for use on specific kinds of objects, via YAML’s
built·in tagging and inclusion mechanisms. Here is an example:

```yaml
properties:
  - &creator # This “tags” the object with `creator`
    name: "creator"
    display_label: "Creator"
    definition: "A person or organization responsible for the intellectual or artistic content of a resource."
    available_on:
    - generic_object
    # …

  - &creator_geospatial
    <<: *creator # Include all properties from &creator
    # `name` is still "creator"
    # `display_label` is still "Creator"
    # Other properties can be overrided:
    definition: "This field represents the originator that will be uploaded to GeoData."
    available_on: # You MUST provide a different availability
    - geospatial_object
    # …
```

## Classes

SurflinerSchema!Houndstooth supports classes. These classes are considered
“conceptual”—there is no guarantee that they will map to, say, a Ruby class.

Classes **must** be declared within the toplevel `classes` property to be fully
supported. The properties of classes are as follows:

- **`name`:** The internal name of the class. This name is used to identify the
  class from elsewhere in the file.

- **`display_label`:** The human‐readable name for the class.

> Samvera!Houndstooth also specifies a `schema_uri` property for classes, but it
> is currently ignored by `surfliner_schema`.

## Mappings

SurflinerSchema!Houndstooth supports named mappings, which are used to identify
how properties might be represented in other schemas.

Mappings **must** be declared within the toplevel `mappings` property to be
fully supported. The properties of mappings are as follows:

- **`name`:** The internal name of the mapping. This name is used to identify
  the mapping from elsewhere in the file.

- **`display_label`:** The human‐readable name for the mapping.

  > This is a SurflinerSchema!Houndstooth addition. Samvera!Houndstooth appears
  > to provide human‐readable names using the `name` property, but this
  > conflicts with the keyed list approach described above.

- **`iri`:** The IRI which identifies the schema being mapped to. This
  **must** be defined; `surfliner_schema` ignores all mappings without an
  associated `iri`.

  > This is a SurflinerSchema!Houndstooth addition.

## Properties

Properties form the core of the schema definition. They are used to define the
attributes of the schema’s conceptual classes, and can supply mappings into
other schemas.

Properties **must** be declared within the toplevel `properties` property. The
properties of properties (oof) are as follows:

- **`name`:** The internal name of the property. This name isn’t referenced
  anywhere else in the file, but it **should** be used by implementations to
  assert property identity across schema versions.

  Schemas **may** include multiple properties of the same name, but they
  **must** have different availabilities.

- **`display_label`:** The human‐readable name for the property.

- **`definition`:** The prose definition for the property.

- **`usage_guidelines`:** Prose usage guidelines for the property.

- **`requirement`:** Human‐readable guidance on whether a value should be
  provided, from a best‐practices standpoint.

- **`available_on`:** The “availability” of the property, which is to say, a
  YAML list of names of classes that the property is available on.

  For backwards‐compatibility, this **may** be specified within a `class`
  subproperty, but this is **optional**. SurflinerSchema!Houndstooth does not
  support a `context` subproperty here.

- **`data_type`:** The (RDF) datatype of the property’s value.

- **`cardinality`:** The (potentially) system‐enforced cardinality of the
  property. This **must** be specified as an object with **optional** `minimum`
  and `maximum` properties. However, only specific combinations are supported:

  - `{ minimum: 1, maximum: 1 }` indicates “exactly one” (`!`)
  - `{ minimum: 1 }` (with no maximum) indicates “one or more” (`+`)
  - `{ maximum: 1 }` (with no minimum) indicates “zero or one” (`?`)
  - The default is “zero or more” (`*`)

- **`indexing`:** How the property should be indexed. The following values are
  supported, with correspondances given as [`hydra-head` suffixes][HydraSolr]
  and `$` corresponding to the “type letter” for the property (currently only
  `s` is supported):

  - `displayable`: Corresponds to `_tsm`
  - `facetable`: Corresponds to `_tim`
  - `searchable`: Corresponds to `_$im`
  - `sortable`: Corresponds to `_$i`
  - `stored_searchable`: Corresponds to `_$sim`
  - `stored_sortable`: Corresponds to `_tsi`
  - `symbol`: Corresponds to `_tsim`
  - `fulltext_searchable`: Corresponds to `_tsimv`

  > These values and correspondances are a best‐effort approximation of what is
  > specified in Samvera!Houndstooth, but they are confusing and probably merit
  > further discussion.

- **`validations`:** An object with a `match_regex` property, which gives a
  regular expression pattern that each value must match to be valid.

- **`mappings`:** An object whose keys are names of mappings, and whose values
  are either:

  - An IRI of the corresponding property in the mapping, or
  - An array of multiple such properties

Defaults are defined for all of the above properties if they are not specified.

> Samvera!Houndstooth allows “context dependent” values for `display_label`,
> `definition`, and `usage_guidelines` by providing an object keyed with class
> names. SurflinerSchema!Houndstooth does not allow this; define a separate
> property with the same name and different availability instead.
>
> Samvera!Houndstooth defines a `controlled_values` property for defining a
> property’s controlled values. SurflinerSchema!Houndstooth does not support
> this yet.
>
> Samvera!Houndstooth defines a `sample_value` property for defining an example
> value for the property. SurflinerSchema!Houndstooth does not support this yet.
>
> Samvera!Houndstooth defines a `property_uri` property for defining a URI which
> is associated with the property. SurflinerSchema!Houndstooth does not support
> this yet.
>
> Samvera!Houndstooth defines a `range` property for defining a class constraint
> on property values. SurflinerSchema!Houndstooth does not support this yet, and
> presently only really supports RDF literal values.
>
> Samvera!Houndstooth defines a `syntax` property for documenting (for humans)
> an advisory syntax for property values. SurflinerSchema!Houndstooth does not
> support this yet.
>
> Samvera!Houndstooth defines a `index_documentation` property for documenting
> (for humans) the indexing of property values. SurflinerSchema!Houndstooth does
> not support this yet.

[HydraSolr]: <https://github.com/samvera/hydra-head/wiki/Solr-Schema>
[Samvera!Houndstooth]: <https://github.com/samvera-labs/houndstooth>
