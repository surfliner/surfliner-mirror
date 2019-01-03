module ApplicationHelper
  # @param manifest_service [ManifestService] a ManifestService containing a SolrDocument that has a IIIF manifest
  # @return [String] the URL to the IIIF manifest
  def iiif_manifest(manifest_service:)
    manifest_service.url
  end
end
