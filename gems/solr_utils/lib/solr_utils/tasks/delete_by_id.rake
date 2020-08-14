# frozen_string_literal: true

require 'rake'
require 'rsolr'

namespace :solr_utils do
  desc 'Delete objects from Solr by ID'
  task delete_by_ids: :environment do
    abort '--- Error: environment variable SOLR_DELETE_IDS is unset' if ENV['SOLR_DELETE_IDS'].blank?

    client = RSolr.connect(
      url: "http://#{ENV['SOLR_HOST']}:#{ENV['SOLR_PORT']}/solr/#{ENV['SOLR_CORE_NAME']}"
    )

    client.delete_by_id ENV['SOLR_DELETE_IDS'].split(',')
    client.commit
  end
end
