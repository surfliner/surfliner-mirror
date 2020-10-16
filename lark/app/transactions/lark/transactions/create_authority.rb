# frozen_string_literal: true

module Lark
  module Transactions
    ##
    # A business transaction handling creation of authorities.
    #
    # @example
    #   tx = CreateAuthority.new(event_stream: Lark.config.event_stream)
    #
    #   tx.call(attributes: { pref_label: 'a preferred label' })
    #   # => Success(Concept)
    #
    # @see https://dry-rb.org/gems/dry-transaction/
    # @see https://dry-rb.org/gems/dry-monads/result/
    class CreateAuthority
      include Dry::Transaction

      ##
      # @param event_stream [#<<]
      def initialize(event_stream:, minter: Lark.config.minter, **_opts)
        @event_stream = event_stream
        @minter = minter
        super
      end

      step :mint_id
      step :log_create_event
      step :log_change_properties_event
      step :build_authority

      private

      ##
      # Mint a unique identifier for authority record
      def mint_id(attributes:)
        id = @minter.mint
        Success(attributes: attributes, id: id)
      rescue Lark::Minter::MinterError => e
        Failure(reason: :minter_failed, message: e.message)
      end

      ##
      # Log changes to properties
      #
      # @param id [String]
      # @param attributes [Hash]
      def log_change_properties_event(id:, attributes:)
        @event_stream <<
          Event.new(type: :change_properties,
                    data: { id: id, changes: attributes })
        Success(id: id, attributes: attributes)
      rescue StandardError => e
        raise Lark::BadRequest, e.message
      end

      def log_create_event(attributes:, id:)
        @event_stream << Event.new(type: :create, data: { id: id })

        Success(attributes: attributes, id: id)
      end

      def build_authority(attributes:, id:)
        Success(Concept.new(id: id, **attributes))
      end
    end
  end
end
