# frozen_string_literal: true

##
# An event in a Record's lifecycle. Events are "append-only" and should never
# be deleted.
#
# Events have:
#   - id:         a system-wide unique identifier
#   - data:       a symbol-keyed `Hash` representing the event data
#   - type:       an event type `Symbol`
#   - created_at  a DateTime timestamp of event creation
class Event < Valkyrie::Resource
  ##
  # @!attribute [rw] data
  #   @return [Hash<Symbol, Object>]
  # @!attribute [rw] id
  #   @return [Valkyrie::ID]
  # @!attribute [rw] type
  #   @return [Symbol]
  # @!attribute [rw] date_created
  #   @return [DateTime]
  attribute :data, Valkyrie::Types::Anything.default({}.freeze)
  attribute :type, Valkyrie::Types::Symbol
  attribute :date_created, Valkyrie::Types::DateTime
end
