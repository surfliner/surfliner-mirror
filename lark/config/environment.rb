# frozen_string_literal: true

require 'dotenv/load' unless ENV['RACK_ENV'] == 'production'

require_relative 'application'

Valkyrie::MetadataAdapter.register(
  Valkyrie::Persistence::Memory::MetadataAdapter.new,
  :memory
)

##
# Register solr metadata adapter with RSolr connection for SOLR persistence
Valkyrie::MetadataAdapter.register(
  Valkyrie::Persistence::Solr::MetadataAdapter
    .new(connection: RSolr.connect(url: ENV['SOLR_URL'])),
  :solr
)

Lark.config.event_adapter = ENV['EVENT_ADAPTER'].to_sym
Lark.config.index_adapter = ENV['INDEX_ADAPTER'].to_sym

Lark.config.event_stream.subscribe(IndexListener.new)
