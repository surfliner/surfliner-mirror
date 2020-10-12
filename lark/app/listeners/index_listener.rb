# frozen_string_literal: true

##
# Listens for events on the event stream, and handles updates to the index as
# needed.
#
# @see https://dry-rb.org/gems/dry-events/
class IndexListener
  ##
  # @!attribute [rw] indexer
  #   @return [Lark::Indexer]
  attr_accessor :indexer

  ##
  # @param indexer [Lark::Indexer]
  def initialize(indexer: Lark::Indexer.new)
    self.indexer = indexer
  end

  ##
  # @param event [Hash<Symbol, Object>]
  #
  # @return [void]
  def on_created(event)
    indexer.index(data: Concept.new(id: event.payload[:authority_id]))
  end

  ##
  # Index an update event
  # @param event [Hash<Symbol, Object>]
  #
  # @return [void]
  def on_properties_changed(event)
    resource = indexer.find(event.payload[:authority_id])
    event.payload[:changes].each do |attribute, value|
      resource.set_value(attribute, value)
    end

    indexer.index(data: resource)
  rescue Valkyrie::Persistence::ObjectNotFoundError => e
    raise Lark::NotFound, e.message
  end
end
