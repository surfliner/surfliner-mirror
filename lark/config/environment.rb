# frozen_string_literal: true

require 'dotenv/load' unless ENV['RACK_ENV'] == 'production'

require_relative 'application'
require_relative 'database'
require 'bundler'

Bundler.require

Lark.config.event_adapter = ENV['EVENT_ADAPTER'].to_sym
Lark.config.index_adapter = ENV['INDEX_ADAPTER'].to_sym

Valkyrie::MetadataAdapter.register(
  Valkyrie::Persistence::Memory::MetadataAdapter.new,
  :memory
)

if Lark.config.event_adapter == :sql
  ##
  # Register postgres metadata adapter
  Valkyrie::MetadataAdapter.register(
    Valkyrie::Sequel::MetadataAdapter.new(
      connection: Sequel.connect(DATABASE)
    ),
    :sql
  )
end

if Lark.config.index_adapter == :solr
  ##
  # Register solr metadata adapter with RSolr connection for SOLR persistence
  Valkyrie::MetadataAdapter.register(
    Valkyrie::Persistence::Solr::MetadataAdapter
      .new(connection: RSolr.connect(url: ENV['SOLR_URL'])),
    :solr
  )

  # Register custom queries for the default Valkyrie metadata adapter
  # (see Valkyrie::Persistence::CustomQueryContainer)
  Valkyrie::MetadataAdapter
    .find(Lark.config.index_adapter)
    .query_service
    .custom_queries
    .register_query_handler(FindByStringProperty)
end

require_relative 'initializers/healthchecks'
require_relative 'initializers/healthchecks_complete'

Lark.config.event_stream.subscribe(IndexListener.new)
