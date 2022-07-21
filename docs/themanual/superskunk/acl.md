# Access Controls in Superskunk

Superskunk uses [Hyrax ACLs][hyrax-acl] to identify which resources a given
discovery platform is allowed to access.

When making a request, a discovery platform **MUST** identify itself using the
`User-Agent` HTTP header. Only the first product name, ignoring any version or
comment, will be recognized. For example, any of the following headers will
properly identify a discovery platform named `my-discovery-platform`:

```http
User-Agent: my-discovery-platform
User-Agent: my-discovery-platform/2 (Ruby 3.1)
User-Agent: my-discovery-platform Ruby/3.1
```

But the following will **not** work:

```http
User-Agent: Ruby/3.1 my-discovery-platform
```

If the `User-Agent` field is missing, Superskunk will respond with a
`403 FORBIDDEN`. Otherwise, it will check the access controls for the requested
resource to see if a `:discover` access grant has been made to a group with that
name. In Hyrax ACLs, group names are prefixed with `group/`, so the
corresponding permission for `my-discovery-platform` will be a grant to an agent
with a key of `group/my-discovery-platform`.

If a `:discover` grant is present, Superskunk will provide the requested
metadata. If not, it will respond with a `404 NOT FOUND`. A `404` is used in
place of a `403` to prevent discovery platforms from being able to distinguish
deletion and unpublishing.

## Future plans for using HTTP Message Signatures

> The following is exploratory. We may eventually choose a different mechanism
> for authenticating discovery platforms.
>
> For the time being, there is no public access to Superskunk and no
> authentication is done.

In order to respond to an API request, the requester must first verify their
identity. The plan for Superskunk is to accomplish this with
[HTTP Message Signatures][ietf-httpbis-message-signatures], which, at time of
writing, are an IETF HTTP Working Group draft.

For each metadata consumer, the following things must be defined:—

1. An identifier
2. A signature algorithm
3. A public key appropriate for the signature algorithm

> TK: Figure out how to make these things available to Superskunk.

To make an API request, an application must first request a nonce. (This
prevents future reuse of signatures.) To get a nonce, make a request to the URI
with headers like the following:—

    Signature-Input: sig1=("@method" "@target-uri" "accept");keyid="$identifier";alg="$algorithm"
    Signature: sig1=:$signature:

Before responding, Superskunk checks to see that the target URI is accessible to
the consumer. If everything checks out, Superskunk will respond with a
`403 Forbidden` and the following header:—

    Accept-Signature: sig1=("@method" "@target-uri" "accept");keyid="$identifier";alg="$algorithm";nonce="$nonce"

The consumer can then reissue the request with the provided nonce to verify its
identity.

If the target URI does not exist or will not allow access to the consumer under
any conditions, a `404 Not Found` will be returned instead.

[hyrax-acl]: <https://github.com/samvera-labs/hyrax-acl>
[ietf-httpbis-message-signatures]: <https://datatracker.ietf.org/doc/html/draft-ietf-httpbis-message-signatures-11>
