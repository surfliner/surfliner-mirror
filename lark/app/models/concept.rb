# frozen_string_literal: true

##
# A full Concept record built from/saved to the index.
#
# @example creating and destroying a concept
#   concept = Concept.new(id: 'my_id', pref_label: 'A Concept')
#   adapter = Valkyrie::MetadataAdapter.find(Lark.config.index_adapter)
#
#   adapter.persister.save(resource: concept)
#   adapter.query_service.find_by(id: 'my_id') # => <#Concept ...>
#   adapter.persister.delete(resource: concept)
#
class Concept < Valkyrie::Resource
  SCHEMA = 'http://www.w3.org/2004/02/skos/core#ConceptScheme'

  ##
  # @!attribute [rw] pref_label
  #   @return [Array<Object>]
  attribute :pref_label, Valkyrie::Types::Set

  ##
  # @!attribute [rw] alternate_label
  #   @return [Array<Object>]
  attribute :alternate_label, Valkyrie::Types::Set

  ##
  # @!attribute [rw] hidden_label
  #   @return [Array<Object>]
  attribute :hidden_label, Valkyrie::Types::Set

  ##
  # @!attribute [rw] exact_match
  #   @return [Array<Valkyrie::Types::URI>]
  attribute :exact_match, Valkyrie::Types::Set.of(Valkyrie::Types::URI)

  ##
  # @!attribute [rw] close_match
  #   @return [Array<Valkyrie::Types::URI>]
  attribute :close_match, Valkyrie::Types::Set.of(Valkyrie::Types::URI)

  ##
  # @!attribute [rw] note
  #   @return [Array<Object>]
  attribute :note, Valkyrie::Types::Set

  ##
  # @!attribute [rw] scope_note
  #   @return [Array<Object>]
  attribute :scope_note, Valkyrie::Types::Set

  ##
  # @!attribute [rw] editorial_note
  #   @return [Array<Object>]
  attribute :editorial_note, Valkyrie::Types::Set

  ##
  # @!attribute [rw] history_note
  #   @return [Array<Object>]
  attribute :history_note, Valkyrie::Types::Set

  ##
  # @!attribute [rw] definition
  #   @return [Array<Object>]
  attribute :definition, Valkyrie::Types::Set

  ##
  # @!attribute [r] scheme
  #   @return [Array<Object>]
  attribute :scheme, Valkyrie::Types::URI

  ##
  # @!attribute [rw] literal_form
  #   @return [Array<Object>]
  attribute :literal_form, Valkyrie::Types::Set

  ##
  # @!attribute [rw] label_source
  #   @return [Array<Valkyrie::Types::URI>]
  attribute :label_source, Valkyrie::Types::Set.of(Valkyrie::Types::URI)

  ##
  # @!attribute [rw] campus
  #   @return [Array<Object>]
  attribute :campus, Valkyrie::Types::Set

  ##
  # @!attribute [rw] annotation
  #   @return [Array<Object>]
  attribute :annotation, Valkyrie::Types::Set

  ##
  # @return [String] constant
  def scheme
    SCHEMA
  end
end
