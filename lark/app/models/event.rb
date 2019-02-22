##
# An event in a Record's lifecycle. Events are "append-only" and should never
# be deleted.
#
# Events have:
#   - id:        a system-wide unique identifier
#   - data:      a symbol-keyed `Hash` representing the event data
#   - type:      an eventtype `Symbol`
class Event < Valkyrie::Resource
  ##
  # @!attribute [rw] data
  #   @return [Hash<Symbol, Object>]
  # @!attribute [rw] id
  #   @return [Valkyrie::ID]
  # @!attribute [rw] type
  #   @return [Symbol]
  attribute :data, Valkyrie::Types::Hash.default({})
  attribute :type, Valkyrie::Types::Symbol
end
