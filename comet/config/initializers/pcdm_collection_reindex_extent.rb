ActiveSupport::Reloader.to_prepare do
  Hyrax::PcdmCollection.class_eval do
    def reindex_extent=(_extent)
      Hyrax.logger.warn("#reindex_extent called on PcdmCollection")
      Hyrax.logger.warn("This is a noop to satify Hyrax::Dashboard::CollectionMembersController#update_members")
    end
  end
end
