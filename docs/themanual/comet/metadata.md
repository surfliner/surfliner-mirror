# Metadata in Comet

## Domain Model

Relationships between `comet`'s resources are managed according to the
[Portland Common Data Model][pcdm] (PCDM). This model was designed to support
rich hierarchies of inter-related **Collections**, **Objects** and **Files**.
PCDM was designed as an abstract data model (a ["conceptual model"][three-schema])
and provides a lightweight [RDF Schema][rdf-schema] to support [semantic web
implementations and serialization into RDF][pcdm-schema].

`comet` also uses the **FileSet** class from the [Hydra::Works][hydra-works]
extension to support grouping derivative (e.g. OCR text, thumbnails) and
administrative files with related content.

## Configuring Metadata

`comet` supports configuration of metadata properties for its PCDM Object
class (`GenericObject`) using a simple YAML format; see
[`ucsb_model.yaml`][yaml-model] for an example.

### Installing a new metadata model

Custom metadata models must first be committed to
[`config/metadata`](https://gitlab.com/surfliner/surfliner/-/tree/trunk/comet/config/metadata).

Available metadata models can be activated by setting the `METADATA_MODELS`
environment variable to a comma-separated list of the desired models (e.g.,
`METADATA_MODELS=ucsb_model,imaginary_model`).


[hydra-works]: https://docs.google.com/drawings/d/1if47TYgEhqDLPh3D0026B_cBLa0BEAOpWPs8AqoQMZE/edit "Hydra::Works Diagram"
[pcdm]: https://github.com/duraspace/pcdm/wiki#portland-common-data-model "Portland Common Data Model Wiki"
[pcdm-schema]: https://pcdm.org/2016/04/18/models "Portland Common Data Model (ontology)"
[rdf-schema]: https://www.w3.org/TR/rdf-schema/ "RDF Schema 1.1"
[three-schema]: https://en.wikipedia.org/wiki/Three-schema_approach "Three-schema approach (Wikipedia)"
[yaml-model]: ../../../comet/config/metadata/ucsb_model.yaml
