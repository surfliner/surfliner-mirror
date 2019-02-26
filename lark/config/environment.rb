# frozen_string_literal: true

require_relative 'application'

Valkyrie::MetadataAdapter.register(
  Valkyrie::Persistence::Memory::MetadataAdapter.new,
  :memory
)

Lark.config.event_adapter = :memory
Lark.config.index_adapter = :memory

Lark.config.event_stream.subscribe(IndexListener.new)
