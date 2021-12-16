# frozen_string_literal: true

require "dotenv/load" unless ENV["RACK_ENV"] == "production"

require "bundler"
require_relative "application"

Bundler.require

Lark.config.event_adapter = ENV["EVENT_ADAPTER"].to_sym
Lark.config.index_adapter = ENV["INDEX_ADAPTER"].to_sym
Lark.config.minter = Lark::Minter.for(ENV.fetch("MINTER", :uuid).to_sym)

Valkyrie::MetadataAdapter.register(
  Valkyrie::Persistence::Memory::MetadataAdapter.new,
  :memory
)

if Lark.config.event_adapter == :sql
  require_relative "database"
  Lark.config.database = DATABASE

  ##
  # Register postgres metadata adapter
  Valkyrie::MetadataAdapter.register(
    Valkyrie::Sequel::MetadataAdapter.new(
      connection: Sequel.connect(Lark.config.database)
    ),
    :sql
  )

  # Register custom queries for event adapter
  # (see Valkyrie::Persistence::CustomQueryContainer)
  [Queries::FindByEventDataProperty, Queries::FindByEventProperty].each do |q|
    Valkyrie::MetadataAdapter
      .find(Lark.config.event_adapter)
      .query_service
      .custom_queries
      .register_query_handler(q)
  end
end

if Lark.config.index_adapter == :solr
  ##
  # Register solr metadata adapter with RSolr connection for SOLR persistence
  Valkyrie::MetadataAdapter.register(
    Valkyrie::Persistence::Solr::MetadataAdapter
      .new(connection: RSolr.connect(url: ENV["SOLR_URL"])),
    :solr
  )

  # Register custom queries for the default Valkyrie metadata adapter
  # (see Valkyrie::Persistence::CustomQueryContainer)
  Valkyrie::MetadataAdapter
    .find(Lark.config.index_adapter)
    .query_service
    .custom_queries
    .register_query_handler(Queries::FindByStringProperty)
end

require_relative "initializers/healthchecks"
require_relative "initializers/healthchecks_complete"

Lark.config.event_stream.subscribe(Listeners::IndexListener.new)
