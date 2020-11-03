# The Lark CSV Batch Import

Lark supports batch import with CSV format. A sample CSV source data file is located at [Sample CSV Import][sample-csv-import].

## Supported Headers/Columns

### Agent
  - `pref_label`: Required
    Preferred label from the external authority identified as exact match.  For local authorities (those with no exactMatch) the preflabel provided by user creating the authority.

  - `alternate_label`: Optional
    Alternative labels which may be displayed - e.g. language variants, campus variants

  - `hidden_label`: Optional
    Character string to be accessible to applications performing text-based indexing and search operations, but would not like that label to be visible otherwise; may not need xl extended label for this

  - `exact_match`: Optional
    Reference(s) to an external vocabulary term (FAST, LCSH, etc.) which has an equivilant meaning, relationships are transitive so exact matches on the linked terms can also be applied to the skos:Concept

  - `close_match`: Optional
    Reference(s) to an external vocabulary term (FAST, LCSH, etc.) skos:closeMatch is used to link two concepts that are sufficiently similar that they can be used interchangeably in some information retrieval applications. In order to avoid the possibility of \"compound errors\" when combining mappings across more than two concept schemes, skos:closeMatch is not declared to be a transitive property. "

  - `scope_note`: Optional
    A note that helps to clarify the identity of the agent.

  - `note`: Optional
    A general note, for any purpose.

  - `editorial_note`: Optional
    Used for information about the entity/concept, possibly documenting information that would help establish a heading, distinguish from similar but non-matching ideas.

  - `history_note`: Optional
    A note that provides information related to the the context a concept record was created for, e.g. collection context, fields, etc, or how it was modified over time.

  - `literal_form`: Optional
    String value of the skos-xl Label.  Can include language qualifier, e.g., "Picasso, Pablo"@en-US

  - `agent_type`: Optional
    Used for encoding what kind of agent is represented (person, organization, group, family, etc.)

  - `identifier`: Optional
    Reference to an external (or internal identifier) that is not a URI.

  - `begin`: Optional
    The beginning date of the entity (e.g. birth, founding, establishment, etc.)

  - `end`: Optional
    The ending date of the entity (e.g. death, dissolution, etc.)

  - `family_name`: Optional
    Name that indicates a person's family, tribe or community.

  - `given_name`: Optional
    Name that identifies a specific person, and differentiates that person from the other members of a group.

  - `label_source`: Optional
    Reference to the external source of the label. Used to select display label ("We always want the FAST label, if there is one") and automatically update label from source vocabulary

  - `campus`: Optional
    Used to indicate campus preference for display label.

  - `annotation`: Optional
    Admin note for information on reason for creating or using an alternative label, i.e., cultural sensitivity.

### Concept
  - `pref_label`: Required
    Preferred label from the external authority identified as exact match.  For local authorities (those with no exactMatch) the preflabel provided by user creating the authority.

  - `alternate_label`: Optional
    Alternative labels which may be displayed - e.g. language variants, campus variants.

  - `hidden_label`: Optional
    Character string to be accessible to applications performing text-based indexing and search operations, but would not like that label to be visible otherwise.

  - `exact_match`: Optional
    Reference(s) to an external vocabulary term (FAST, LCSH, etc.) which has an equivilant meaning, relationships are transitive so exact matches on the linked terms can also be applied to the skos:Concept.

  - `close_match`: Optional
    Reference(s) to an external vocabulary term (FAST, LCSH, etc.) skos:closeMatch is used to link two concepts that are sufficiently similar that they can be used interchangeably in some information retrieval applications. In order to avoid the possibility of \"compound errors\" when combining mappings across more than two concept schemes, skos:closeMatch is not declared to be a transitive property.

  - `note`: Optional
    A general note, for any purpose.

  - `scope_note`: Optional
    A note that helps to clarify the meaning and/or the use of a concept.

  - `editorial_note`: Optional
    Used for information about the entity/concept, possibly documenting information that would help establish a heading, distinguish from similar but non-matching ideas.

  - `history_note`: Optional
    A note that provides information related to the the context a concept record was created for, e.g. collection context, fields, etc, or how it was modified over time.

  - `definition`: Optional
    A statement or formal explanation of the meaning of a concept.

  - `literal_form`: Optional
    String value of the skos-xl Label.  Can include language qualifier, e.g., "photographs"@en-US.

  - `label_source`: Optional
    Reference to the external source of the label.  Used to select display label ("We always want the FAST label, if there is one") and automatically update label from source vocabulary.

  - `campus`: Optional
    Used to indicate campus preference for display label.

  - `annotation`: Optional
    Admin note for information on reason for creating or using an alternative label, i.e., cultural sensitivity.

  - `identifier`: Optional
    Reference to an external or internal identifier that is not a URI. Value should include an indication of the identifier source.


## Importing Authority Records 

```sh
curl -v --data-binary @/filepath_for_csv/UCSD_authority_sample_2.csv -H "Content-Type: text/csv" http://localhost:9292/batch_import
```

Response
```
HTTP/1.1 201 Created
Content-Type: application/json
Access-Control-Allow-Origin: *
X-Content-Type-Options: nosniff
```

### Error Cases

#### With unsupported attributes in csv file
```sh
curl -v --data-binary @/filepath_for_csv/UCSD_authority_sample_1.csv -H "Content-Type: text/csv" http://localhost:9292/batch_import
```

Response
```
HTTP/1.1 400 Bad Request
Content-Type: text/html;charset=utf-8
Access-Control-Allow-Origin: *
```

#### With unsupported format
```sh
curl -v --data-binary @/filepath_for_csv/UCSD_authority_sample_1.csv -H "Content-Type: application/fake" http://localhost:9292/batch_import
```

```
HTTP/1.1 415 Unsupported Media Type
Content-Type: text/html;charset=utf-8
Access-Control-Allow-Origin: *

```

#### With file does not exist

```sh
curl -v --data-binary @/not_exist_file.csv -H "Content-Type: text/csv" http://localhost:9292/batch_import
```

Response
```
HTTP/1.1 400 Bad Request
Content-Type: text/html;charset=utf-8
Access-Control-Allow-Origin: *
```


[sample-csv-import]: https://gitlab.com/surfliner/surfliner/blob/master/lark/spec/fixtures/UCSD_authority_sample_2.csv
