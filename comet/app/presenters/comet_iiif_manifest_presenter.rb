# frozen_string_literal: true

##
# This presenter wraps objects in the interface required by +IIIFManifiest+.
# It will accept either a Work-like resource or a {SolrDocument}.
#
# @example with a work
#
#   monograph = Monograph.new
#   presenter = CometIiifManifestPresenter.new(monograph)
#   presenter.title # => []
#
#   monograph.title = ['Comet in Moominland']
#   presenter.title # => ['Comet in Moominland']
#
# @see https://www.rubydoc.info/gems/iiif_manifest
class CometIiifManifestPresenter < Hyrax::IiifManifestPresenter
  class << self
    ##
    # @param [Hyrax::Resource, SolrDocument] model
    def for(model)
      klass = if model.file_set?
        Hyrax::IiifManifestPresenter::DisplayImagePresenter
      else
        CometIiifManifestPresenter
      end

      klass.new(model)
    end
  end

  def description
    Array(super).first || ""
  rescue NoMethodError
    ""
  end

  def member_ids
    model["member_ids_ssim"]
  end

  def rendering_ids
    model["rendering_ids_ssim"]
  end

  ##
  # IIIF metadata for inclusion in the manifest
  #  Called by the `iiif_manifest` gem to add metadata
  #
  # @todo should this use the simple_form i18n keys?! maybe the manifest
  #   needs its own?
  #
  # @return [Array<Hash{String => String}>] array of metadata hashes
  def manifest_metadata
    metadata_fields.map do |field_name|
      {
        "label" => I18n.t("simple_form.labels.defaults.#{field_name}"),
        "value" => Array(self[field_name]).map { |value| scrub(value.to_s) }
      }
    end
  end
end
