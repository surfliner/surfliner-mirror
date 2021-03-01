# frozen_string_literal: true

# Mount the health endpoint at /healthz
# Review all health checks at /healthz/all
OkComputer.mount_at = "healthz"

# Setup additional services
# OKComputer provides app/default and ActiveRecord 'out of the box'
require "starlight/solr_ping_check"
require "starlight/solr_collection_check"
OkComputer::Registry.register "solr", Starlight::SolrPingCheck.new
OkComputer::Registry.register "solr_collection", Starlight::SolrCollectionCheck.new
