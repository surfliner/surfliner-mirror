# frozen_string_literal: true

module Lark
  module Transactions
    ##
    # A business transaction on handling update of authorities.
    #
    # @example
    #   tx = UpdateAuthority.new(event_stream: Lark.config.event_stream,
    #                            adapter:      Lark.config.index_adapter)
    #
    #   tx.call(attributes: { id: 'record_id', pref_label: 'a label' })
    #   # => Success(Concept)
    #
    # @see https://dry-rb.org/gems/dry-transaction/
    # @see https://dry-rb.org/gems/dry-monads/result/
    class UpdateAuthority
      include Dry::Transaction

      ##
      # @param event_stream [#<<]
      def initialize(event_stream:, adapter:, **_opts)
        @adapter      = adapter
        @event_stream = event_stream
        super
      end

      step :log_change_properties_event
      step :update_authority

      ##
      # create event
      # @param attributes [Hash]
      # @param adapter [MetadataAdapter]
      def log_change_properties_event(id:, attributes:)
        @event_stream <<
          Event.new(type: :change_properties,
                    data: { id: id, changes: attributes })
        Success(id: id, attributes: attributes)
      end

      ##
      # update an existing authority record
      # @param id [String]
      # @param attributes [Hash]
      # @param adapter [MetadataAdapter]
      def update_authority(id:, attributes:)
        authority = @adapter.query_service.find_by(id: Valkyrie::ID.new(id))

        attributes.each do |k, v|
          if authority.has_attribute?(k.to_s) && authority.send(k.to_s) != v
            authority.send("#{k}=", attributes[k])
          end
        end

        Success(@adapter.persister.save(resource: authority))
      end
    end
  end
end
