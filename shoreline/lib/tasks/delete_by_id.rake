# frozen_string_literal: true

$stdout.sync = true

require "rsolr"

namespace :shoreline do
  desc "Delete objects from Solr by ID"
  task delete_by_ids: :environment do
    abort "--- Error: environment variable SOLR_DELETE_IDS is unset" if ENV["SOLR_DELETE_IDS"].blank?
    abort "--- ERROR: environment variable SOLR_URL is unset" if ENV["SOLR_URL"].blank?

    client = RSolr.connect(url: ENV["SOLR_URL"])
    client.delete_by_id ENV["SOLR_DELETE_IDS"].split(",")
    client.commit
  end
end
