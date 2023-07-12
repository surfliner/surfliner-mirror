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

  def to_s
    Array(self[:title]).first ||
      Array(self[:label]).first ||
      super
  end

  ##
  # IIIF::Manifest will drop the whole structure if any labels or values are not
  # present. Filter them preemptively to avoid this.
  def manifest_metadata
    super.reject do |v|
      v["label"].blank? || v["value"].blank?
    end
  end

  private

  def metadata_fields
    super.intersection(model.class.fields)
  end
end
