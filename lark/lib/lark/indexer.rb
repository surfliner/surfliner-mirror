# frozen_string_literal: true

module Lark
  ##
  # This service persists objects to the index.
  #
  # @example
  #   indexer = Indexer.new
  #
  #   indexer.index(id: 'an_id')
  #
  class Indexer
    ##
    # @!attribute [rw] adapter
    #   @return [Valkyrie::MetadataAdapter]
    attr_accessor :adapter

    ##
    # @param adapter [Valkyrie::MetadataAdapter]
    def initialize(adapter:
                     Valkyrie::MetadataAdapter.find(Lark.config.index_adapter))
      self.adapter = adapter
    end

    ##
    # @param data [Hash<Symbol, Object>]
    def index(data:)
      persister.save(resource: Concept.new(data))
    end

    private

    def persister
      adapter.persister
    end
  end
end
