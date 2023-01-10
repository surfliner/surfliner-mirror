How does `comet` handle file storage?
=====================================

One of ~comet's core functions is to manage files related to Digital Objects.
It's typical for Objects to have a number of files which may represent different
parts of the Object or provide different representations, formats and levels of
quality. These files are not all created equal when it comes to storage
requirements and appropriateness for preservation. ~comet's model designates
each file as having a particular _Use_, specifying its purpose within an Object.
This information can be used to help the system decide how best to store file
content.

This model is designed to support a simple split between high durability
repository storage and storage for access copies which is described below. We
anticipate that campuses may need to support more sophisticated storage
requirements in the future; e.g. storing some content on-premises, supporting
per-project grant-funded storage, or replicating across cloud providers. The
architecture is intended to be flexible to these kinds of emerging needs.

> ※ This document addresses storage for files under managament (i.e.
> "repository" or "digital library" content). ~comet handles many files that are
> not, or not yet, under management, e.g. batch metadata submissions and uploads
> to the _New Object_ form (prior to ingest). These files are held in shared
> _application storage_, which is separate from the storage described here.

## Storage Buckets

~comet's storage is organized into "buckets" which act as containers for file
objects. These buckets can be thought of as storage locations; files within a
bucket share properties relevant to cost modeling including versioning support,
replication and access tier.

In its current configuration, ~comet supports two buckets: a _primary storage_
bucket which should be configured for cost efficient long term storage and
flexible or infrequent access (note: this is called _"Comet Storage"_ in some
Surfliner diagrams); and an _access storage_ bucket which stores system
generated derivatives and other access copies. Splitting content into these
two buckets allows campuses to manage costs for long term repository storage
separately from access needs.

~comet uses the AWS S3 API as its interface to storage buckets. This allows
campuses to use cloud storage provided by AWS as well as a variety of S3
Compatible storage platforms which are available from other cloud providers and
can be deployed on-premises. We actively test ~comet against [MinIO][minio]
to ensure multi-platform storage support. The durability, responsiveness, and costs
associated with each bucket will vary based on the individual deployment.

## Versioning

TK: [How versioning works][s3-versioning]

## File _Uses_

TK: [PCDM Use Vocabulary][pcdm-use] & per campus extensions.

## Digital Preservation

~comet is designed as a repository for content under active management. While
its storage support is intended to be reliable and highly durable, it is not
designed as a _digital preservation_ platform. Instead, we envision ~comet
integrating with external platforms to provide for long term preservation.

Another way of viewing this is to say that ~comet has a role in the
_preservation planning_ function of the overall Digital Library, but that it
doesn't provide the technical implementation for _preservation storage_. As
~comet's role in preservation evolves, we plan to develop integrations to
external preservation platforms following the model outlined by the 2020
[One-to-Many][one-to-many] grant.

### File Fixity

~comet's storage durability is primarily a function of the durability of the
object storage layer used for its buckets. Object storage systems normally
provides some degree of replication in support of their durability claims.
Where needed, additional techniques for replication can be employed at the
bucket layer, e.g. to provide cross-region replication . The details of storage
durability are therefore dependent on configuration of the individual deployment.

Instead of providing a blanket durability guarantee directly, ~comet seeks to
provide tools for managing file fixity. The fixity functionality is intended
to provide a degree of control and auditibility from at various points in the
management lifecycle.

__On ingest__ we ensure checksums provided with file content are consistent with
ingested content by checking fixity prior to ingest. Additionally, ~comet
generates digests [alg support?] of the content as received and stores them in
the metadata store. These digests are checked against those calculated by the
storage layer on upload [do/can we use `Content-MD5` header? HTTP Trailer?] to
ensure fixity through the ingest process.

These ingest time fixity checks seek to provide [NDSA Level][ndsa] 1 [benefits][dpc-fixity]:

>  - Corrupted or incorrect digital materials are not knowingly stored.
>  - Authenticity of the digital materials can be asserted.
>  - Baseline fixity established so unwanted data changes have potential to be detected.

__Periodically__: TK

> note: There are open questions about the goals of periodic fixity checks given
> the storage model. for ~comet, we might choose to be satisfied that the storage
> layer "takes care of it", delegating the requirements for what that means to
> individual deployments.
>
> The S3 API doesn't provide a mechanism guaranteeing an active fixity check for
> data at rest on the storage layer. If ~comet wants to actively check fixity,
> it probably needs to do so by downloading content and running checksums
> locally. This strategy has some sense to it: if ~comet wants to manage fixity
> of the content it has access to, it needs to check on realistic access. A
> downside is a relatively high likelihood of false positives for corruption, as
> the most likely place for corruption to occur is in the network transfer to
> ~comet itself.
>
> Periodic fixity checks are introduced at [NDSA Level 3][ndsa], which requires
> we "Check fixity of content at fixed intervals" (why fixed?) and "Maintain
> logs of fixity info; supply audit on demand". The goal of these capabilities
> seems to be to provide the "Ability to detect corrupt data". Is this goal
> meaningful in the context of an "11 nines of durability" service level from
> the storage layer? What other goals might we have for active fixity checks?

__Event Driven__: TK
__Audit Logging__: TK


[comet-metadata]: ./metadata.yaml
[dpc-fixity]: https://www.dpconline.org/handbook/technical-solutions-and-tools/fixity-and-checksums
[ndsa]: https://www.digitalpreservation.gov/documents/NDSA_Levels_Archiving_2013.pdf
[minio]: https://min.io/
[one-to-many]: https://wiki.lyrasis.org/display/OTM
[pcdm-use]: https://pcdm.org/2015/05/12/use
[s3-get-object-attrs]: https://docs.aws.amazon.com/AmazonS3/latest/API/API_GetObjectAttributes.html
[s3-versioning]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/versioning-workflows.html
