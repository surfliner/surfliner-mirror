## Metadata in Comet

### Configuring which metadata models are loaded

Custom metadata models must first be committed to
[`config/metadata`](https://gitlab.com/surfliner/surfliner/-/tree/trunk/comet/config/metadata);
see `ucsb_model.yaml` for an example.

Available metadata models can be activated by setting the `METADATA_MODELS`
environment variable to a comma-separated list of the desired models (e.g.,
`METADATA_MODELS=ucsb_model,imaginary_model`).
