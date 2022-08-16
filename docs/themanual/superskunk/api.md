# Superskunk API Endpoints

### GET `/resources/:id`

Get the metadata for a resource. The discovery platform making the request must
identify itself as described in [Access Controls](./acl.md). The `Accept` header
of the request is used to determine the format of the response. The following
values are recognized:

- `application/ld+json;profile="tag:surfliner.gitlab.io,2022:api/oai_dc"`:
  [OAI/DC metadata](./profiles/oai_dc.md)

A generic `Accept` value like `application/json` or `*/*` will default to an
OAI/DC response.

### GET `/acls`

This endpoint requires the following parameters:

- `resource` or `file`: The ID of a Valkyrie resource, or the ID of a file.
  Files are resolved by querying Valkyrie for a resource with a corresponding
  `file_identifier`; it is expected that this will be a `FileMetadata` resource.

- `mode`: The access mode for the ACL.

- `group`: The group attempting access.

It will return `0` if the resource does not exist or access is prohibited, and
`1` otherwise.
