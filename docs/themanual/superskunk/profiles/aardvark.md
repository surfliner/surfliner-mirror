# Aardvark Metadata

**Media Type:**
`application/ld+json;profile="tag:surfliner.gitlab.io,2022:api/aardvark"`

## Response Format

A successful Aardvark response will be a single JSON(‐LD) object. It is **not
required** that metadata consumers support JSON‐LD.

Ignoring the JSON‐LD `@context`, the properties and values of this object will
match those defined in [OGM Aardvark][]. All multi‐valued properties will be
given as an array, even if the property contains only one value.  When a
single‐valued property has multiple values in the database, only the first is
given.

Properties whose names start with `gbl_` are assigned an IRI which begins with
`http://geoblacklight.org/schema/aardvark/`. All other properties are equated
with the corresponding IRI in the relevant specification (for example,
`http://www.w3.org/ns/locn#geometry` for `locn_geomerty`). These IRIs are
defined in the `@context` for JSON‐LD consumers, but can be safely ignored by
others.

### Special Properties

As a general rule, the values of OGM Aardvark properties are defined by the
mappings which have been made in M3. However, a few properties require special
consideration, which are noted here.

#### Fallbacks for Required Properties

All of the required OGM Aardvark properties have defined fallbacks if no mapping
is defined in the M3. For many of these properties, the fallback behaviour may
be what is desired.

- `dct_accessRights_s` (“Access Rights”): Falls back to `"Public"`.

- `id` (“ID”): Falls back to the ID which was used to make the request.

- `gbl_mdVersion_s` (“Metadata Version”): Falls back to `"Aardvark"`.

- `gbl_mdModified_dt` (“Modified”): Falls back to the Hyrax last‐modified date,
  or the current date if the former is undefined.

- `gbl_resourceClass_sm` (“Resource Class”): Falls back to `"Datasets"`.

- `dct_title_s` (“Title”): Falls back to the Hyrax `title`.

[OGM Aardvark]: https://opengeometadata.org/docs/ogm-aardvark
