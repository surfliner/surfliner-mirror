# frozen_string_literal: true

module ApplicationHelper
  # @param manifest_service [ManifestService] a ManifestService containing a SolrDocument that has a IIIF manifest
  # @return [String] the URL to the IIIF manifest
  def iiif_manifest(manifest_service:)
    manifest_service.url
  end

  def resource_upload_path(document)
    Spotlight::Resources::Upload.find(document.id.to_s.split("-").last).upload.image.to_s
  end

  def resource_render_type(document)
    is_pdf = File.extname(resource_upload_path(document)).start_with?(".pdf")

    (is_pdf ? "catalog/pdf" : "catalog/universal_viewer")
  end

  # Override ActionView::Helpers::TranslationHelper#translate to attempt to use
  # translation keys defined for the current theme.
  #
  # Depends on +scoped_themed_translation_key_by_partial+, defined in
  # config/initializers/action_view_translate.rb.
  def translate(key, **options)
    key = key&.to_s unless key.is_a?(Symbol)
    begin
      # Attempt to translate the given key with the current theme. This will
      # raise an error if no such key exists, which will be rescued by calling
      # `super`.
      scoped_key = scoped_themed_translation_key_by_partial(key)
      scoped_options = options.clone
      scoped_options[:raise] = true
      super(scoped_key, **scoped_options)
    rescue
      super
    end
  end
  alias_method :t, :translate
end
