# OAI/DC Metadata

**Media Type:**
`application/ld+json;profile="tag:surfliner.gitlab.io,2022:api/oai_dc"`

## Response Format

A successful OAI/DC response will be a single JSON(‐LD) object.
It is **not required** that metadata consumers support JSON‐LD.

Some properties are defined as producing “field values”, which are
  defined as one of the following values&#x202F;:—

 +  A string.

 +  An object with `@language` and `@value` properties, representing a
      language‐tagged string.

 +  An array of two or more strings or language‐tagged strings.

## API Endpoints

### GET `/objects/:id`

The response will be a JSON object with the following
  properties&#x202F;:—

<dl>
  <dt><code>@context</code></dt>
  <dd>

The following object&#x202F;:—

```json
{
  "@vocab": "http://purl.org/dc/elements/1.1/",
  "ore": "http://www.openarchives.org/ore/terms/"
}
```

This property can be safely ignored by consumers that do not need to
  interpret JSON‐LD.

  </dd>
  <dt><code>@id</code></dt>
  <dd>

A permanent, unique identifier for the object, conforming to
  [RFC&#x202F;3987][rfc3987].

This identifier is not intended to be exposed to downstream recipients
  as a formal identifier of the underlying Object.

  </dd>
  <dt><code>contributor</code> (optional)</dt>
  <dt><code>coverage</code> (optional)</dt>
  <dt><code>creator</code> (optional)</dt>
  <dt><code>date</code> (optional)</dt>
  <dt><code>description</code> (optional)</dt>
  <dt><code>format</code> (optional)</dt>
  <dt><code>identifier</code> (optional)</dt>
  <dt><code>language</code> (optional)</dt>
  <dt><code>publisher</code> (optional)</dt>
  <dt><code>relation</code> (optional)</dt>
  <dt><code>rights</code> (optional)</dt>
  <dt><code>source</code> (optional)</dt>
  <dt><code>subject</code> (optional)</dt>
  <dt><code>title</code> (optional)</dt>
  <dt><code>type</code> (optional)</dt>
  <dd>

A field value, as defined above.
Not every property will necessarily be present on every Object.

  </dd>
  <dt><code>ore:isAggregatedBy</code> (optional)</dt>
  <dd>

An object, representing the “collection” or “set” to which the Object
  belongs.
Its value will be either an object or an array of two or more objects,
  each with the following properties&#x202F;:—

<dl>
  <dt><code>@id</code></dt>
  <dd>

A permanent, unique identifier for the collection, conforming to
  [RFC&#x202F;3987][rfc3987].

This identifier is not intended to be exposed to downstream recipients.

  </dd>
  <dt><code>title</code></dt>
  <dd>

A human‐readable name for the collection, as a string.

  </dd>
</dl>

  </dd>
</dl>

Sample response&#x202F;:—

```json
{
  "@context": {
    "@vocab": "http://purl.org/dc/elements/1.1/",
    "ore": "http://www.openarchives.org/ore/terms/"
  },
  "@id": "example:cs/0112017",
  "title": {
    "@value": "Using Structural Metadata to Localize Experience of Digital Content",
    "@language": "en"
  },
  "creator": "Dushay, Naomi",
  "subject": "Digital Libraries",
  "description": [
    {
      "@value": "With the increasing technical sophistication of both information consumers and providers, there is increasing demand for more meaningful experiences of digital information. We present a framework that separates digital object experience, or rendering, from digital object storage and manipulation, so the rendering can be tailored to particular communities of users.",
      "@language": "en"
    },
    "Comment: 23 pages including 2 appendices, 8 figures"
  ],
  "date": "2001-12-14",
  "type": "e-print",
  "identifier": "http://arXiv.org/abs/cs/0112017",
  "ore:isAggregatedBy": [
    {
      "@id": "example:cs",
      "title": "Computer Science"
    },
    {
      "@id": "example:math",
      "title": "Mathematics"
    }
  ]
}
```

[rfc3987]: https://www.rfc-editor.org/rfc/rfc3987.html
