module ApplicationHelper
  # @param manifest_service [ManifestService] a ManifestService containing a SolrDocument that has a IIIF manifest
  # @return [String] the URL to the IIIF manifest
  def iiif_manifest(manifest_service:)
    manifest_service.url
  end

  def resource_upload_path(document)
    Spotlight::Resources::Upload.find(document.id.to_s.split('-').last).upload.image.to_s
  end

  def resource_render_type(document)
    is_pdf = (File.extname(resource_upload_path(document)) == '.pdf')

    (is_pdf ? "catalog/pdf" : "catalog/universal_viewer")
  end
end
