# frozen_string_literal: true

# Mount the health endpoint at /health
# Review all health checks at /health/all
OkComputer.mount_at = "health"

# Setup additional services
# OKComputer provides app/default and ActiveRecord 'out of the box'
OkComputer::Registry.register "solr", OkComputer::SolrCheck.new(ENV.fetch("SOLR_URL"))
