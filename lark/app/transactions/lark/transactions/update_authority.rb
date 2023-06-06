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
    #   tx.call(attributes: { id: 'authority_id', pref_label: 'a label' })
    #   # => Success(Concept)
    #
    # @see https://dry-rb.org/gems/dry-transaction/
    # @see https://dry-rb.org/gems/dry-monads/result/
    class UpdateAuthority
      include Dry::Transaction

      ##
      # @param adapter [Valkyrie::MetadataAdapter]
      # @param event_stream [#<<]
      def initialize(event_stream:, adapter:, **_opts)
        @adapter = adapter
        @event_stream = event_stream
        super
      end

      step :validate_change_properties
      step :log_change_properties_event
      step :build_authority

      private

      # TODO: In the case that the +attributes+ contain labels, they might be
      # one of a number of different forms. We should probably add a step to
      # normalize them to an actual +Label+ instance before we run the
      # validation steps so that we are logging them consistently.
      #
      # It might be worthwhile to do normalization of other attributes to
      # arrays of +RDF::Literal+s as well.

      def validate_change_properties(id:, attributes:)
        result = Contracts::AuthorityContract[:concept].new.call(attributes)

        return Success(id: id, attributes: attributes) if result.success?

        Failure(reason: :invalid_attributes, message: result.errors(full: true).to_h)
      end

      ##
      # Log changes to properties
      #
      # @param id [String]
      # @param attributes [Hash]
      def log_change_properties_event(id:, attributes:)
        @event_stream <<
          Event.new(type: :change_properties,
            data: {authority_id: id, changes: attributes})
        Success(id: id, attributes: attributes)
      end

      def build_authority(attributes:, id:)
        Success(Concept.new(id: id, **attributes))
      end
    end
  end
end
