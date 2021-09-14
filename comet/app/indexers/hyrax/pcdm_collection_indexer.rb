# frozen_string_literal: true

module Hyrax
  class PcdmCollectionIndexer < Hyrax::ValkyrieIndexer
    include Hyrax::ResourceIndexer
    include Hyrax::PermissionIndexer
    include Hyrax::VisibilityIndexer
    include Hyrax::Indexer(:core_metadata)

    def to_solr
      super.tap do |index_document|
        index_document[Hyrax.config.collection_type_index_field.to_sym] = Array(resource.try(:collection_type_gid)&.to_s)
        index_document[:has_model_ssim] = "Collection"
        index_document[:generic_type_sim] = ["Collection"]
        index_document[:thumbnail_path_ss] = Hyrax::CollectionThumbnailPathService.call(resource)
        index_document[:depositor_ssim] = resource.try(:depositor)
      end
    end
  end
end
