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
    # @param id [#to_s]
    #
    # @return [Valkyrie::Resource]
    # @raise  [Valkyrie::Persistence::ObjectNotFoundError]
    def find(id)
      query_service.find_by(id: Valkyrie::ID.new(id.to_s))
    end

    ##
    # @param data [Valkyrie::Resource]
    def index(data:)
      raise ArgumentError, "ID missing: #{data.inspect}" unless data.id

      persister.save(resource: data)
    end

    private

    def persister
      adapter.persister
    end

    def query_service
      adapter.query_service
    end
  end
end
