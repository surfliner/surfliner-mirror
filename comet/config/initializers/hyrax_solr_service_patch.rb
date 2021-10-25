ActiveSupport::Reloader.to_prepare do
  Hyrax::SolrService.class_eval do
    def valkyrie_index
      Hyrax.index_adapter
    end
  end
end
