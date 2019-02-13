require_relative 'application'

Valkyrie::MetadataAdapter.register(
  Valkyrie::Persistence::Memory::MetadataAdapter.new,
  :memory
)

Lark.config.index_adapter = :memory
