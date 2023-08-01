# frozen_string_literal: true

namespace :comet do
  namespace :index do
    desc "Reindex all resources in the Comet metadata database"
    task reindex: :environment do
      Hyrax.query_service.find_all.each do |resource|
        Hyrax.index_adapter.save(resource: resource)
      end
    end

    desc "Wipe the comet solr index"
    task wipe: :environment do
      Hyrax.index_adapter.wipe!
    end
  end
end
