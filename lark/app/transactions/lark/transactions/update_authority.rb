# frozen_string_literal: true

module Lark
  module Transactions
    ##
    # A business transaction on handling update of authorities.
    #
    # @example
    #   tx = UpdateAuthority.new(event_stream: Lark.config.event_stream)
    #
    #   tx.call(attributes: { id: 'record_id', pref_label: 'a label' },
    #                         adapter: Lark.config.index_adapter)
    #   # => Success(Concept)
    #
    # @see https://dry-rb.org/gems/dry-transaction/
    # @see https://dry-rb.org/gems/dry-monads/result/
    class UpdateAuthority
      include Dry::Transaction

      ##
      # @param event_stream [#<<]
      def initialize(event_stream:, **_opts)
        @event_stream = event_stream
        super
      end

      step :log_create_event
      step :update_authority

      ##
      # create event
      # @param attributes [Hash]
      # @param adapter [MetadataAdapter]
      def log_create_event(id:, attributes:, adapter:)
        @event_stream << Event.new(type: :update, data: { id: id })
        Success(id: id, attributes: attributes, adapter: adapter)
      end

      ##
      # update an existing authority record
      # @param id [String]
      # @param attributes [Hash]
      # @param adapter [MetadataAdapter]
      def update_authority(id:, attributes:, adapter:)
        authority = adapter.query_service.find_by(id: Valkyrie::ID.new(id))
        attributes.each do |k, v|
          if authority.has_attribute?(k.to_s) && authority.send(k.to_s) != v
            authority.send("#{k}=", attributes[k])
          end
        end

        Success(adapter.persister.save(resource: authority))
      end
    end
  end
end
