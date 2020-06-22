# frozen_string_literal: true

# Mount the health endpoint at /healthz
# Review all health checks at /healthz/all
OkComputer.mount_at = "healthz"

# Setup additional services
# OKComputer provides app/default and ActiveRecord 'out of the box'
OkComputer::Registry.register "solr", OkComputer::SolrCheck.new(ENV.fetch("SOLR_URL"))
