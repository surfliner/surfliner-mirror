# Access Controls in Superskunk

> Access controls have not yet been implemented; this document is currently
> speculative.

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

[ietf-httpbis-message-signatures]: <https://datatracker.ietf.org/doc/html/draft-ietf-httpbis-message-signatures-08>
