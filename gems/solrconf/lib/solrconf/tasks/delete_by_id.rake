# frozen_string_literal: true

require 'rake'
require 'rsolr'

namespace :solrconf do
  desc 'Delete objects from Solr by ID'
  task :delete_by_ids => :environment do

    if ENV['SOLR_DELETE_IDS'].blank?
      abort "--- Error: environment variable SOLR_DELETE_IDS is unset"
    end

    client = RSolr.connect(
      url: "http://#{ENV['SOLR_HOST']}:#{ENV['SOLR_PORT']}/solr/#{ENV['SOLR_CORE_NAME']}"
    )

    client.delete_by_id ENV['SOLR_DELETE_IDS'].split(',')
    client.commit
  end
end
