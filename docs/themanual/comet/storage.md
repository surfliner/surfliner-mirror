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

This model is designed to support a simple split between long term repository
storage and storage for access copies which is described below. We anticipate
that campuses may need to support more sophisticated storage requirements in
the future; e.g. storing some content on-premises, supporting per-project
grant-funded storage, or replicating across cloud providers. The architecture
is intentended to be flexible to these kinds of emerging needs.

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
to ensure multi-platform storage support.

## File _Uses_


## Digital Preservation



[comet-metadata]: ./metadata.yaml
[minio]: https://min.io/
[one-to-many]: https://wiki.lyrasis.org/display/OTM
[pcdm-use]: https://pcdm.org/2015/05/12/use
