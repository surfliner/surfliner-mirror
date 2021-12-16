# frozen_string_literal: true

module Lark
  ##
  # This service reindex .
  #
  # @example
  #   reindexer = Reindexer.new
  #
  #   reindexer.reindex(id: 'an_id')
  #   reindexer.reindex_all
  #
  class Reindexer
    ##
    # @!attribute [rw] adapter, event_adapter
    #   @return [Valkyrie::MetadataAdapter]
    attr_accessor :adapter, :event_adapter, :event_stream, :indexer

    ##
    # @param adapter [Valkyrie::MetadataAdapter]
    def initialize(adapter:
                     Valkyrie::MetadataAdapter.find(Lark.config.index_adapter),
      event_adapter:
        Valkyrie::MetadataAdapter.find(Lark.config.event_adapter),
      event_stream: Lark.config.event_stream,
      indexer: Lark::Indexer.new)

      self.adapter = adapter
      self.event_adapter = event_adapter
      self.event_stream = event_stream
      self.indexer = indexer
    end

    ##
    # Reindex all authority record by retrieving them from event log
    def reindex_all
      ids = search_all_records
      ids.each do |id|
        reindex_record(id: id)
      rescue => e
        puts "Rescued: #{e.inspect}"
      end

      ids
    end

    ##
    # Reindex an existing authority record from event log
    def reindex_record(id:)
      resource = indexer.find(id)

      attributes = retrieve_attributes(id)
      attributes.each do |attribute, value|
        resource.set_value(attribute, value)
      end

      indexer.index(data: resource)
    rescue Valkyrie::Persistence::ObjectNotFoundError
      indexer.index(data: Concept.new(id: id, **attributes))
    end

    private

    ##
    # retrieve attributes from event logging
    # @params [authority_id] the id of the authority record
    def retrieve_attributes(authority_id)
      attributes = {}
      search_events(authority_id).each do |event|
        next unless event.data[:changes]

        changes = event.data[:changes]
        attributes = attributes.merge(changes) unless changes.is_a?(Array)
        changes.each_slice(2) { |s| attributes[s[0].to_sym] = s[1] } if changes.is_a?(Array)
      end

      attributes
    end

    ##
    # perform search on events
    # @params [authority_id] the id of the authority record
    def search_events(authority_id)
      event_adapter.query_service.custom_queries
        .find_by_event_data_property(property: :authority_id,
          value: authority_id)
    end

    ##
    # perform search for all records created
    # @params [authority_id] the id of the authority record
    def search_all_records
      event_adapter.query_service.custom_queries
        .find_by_event_property(property: :type, value: :create)
        .map { |event| event.data[:authority_id] }
    end
  end
end
