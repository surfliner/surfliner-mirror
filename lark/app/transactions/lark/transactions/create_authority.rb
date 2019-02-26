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
      def initialize(event_stream:, **_opts)
        @event_stream = event_stream
        super
      end

      step :mint_id
      step :log_create_event
      step :build_authority

      private

      def mint_id(attributes:, id: SecureRandom.uuid)
        Success(attributes: attributes, id: id)
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
