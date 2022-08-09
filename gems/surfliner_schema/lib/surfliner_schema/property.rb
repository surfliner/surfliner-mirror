# frozen_string_literal: true

require "valkyrie"

module SurflinerSchema
  ##
  # A metadata property definition.
  class Property < Dry::Struct
    # § PROPERTY NAME ##########################################################

    ##
    # The internal name used for the property.
    attribute :name, Valkyrie::Types::Coercible::Symbol

    # § DEFINED BY HOUNDSTOOTH #################################################

    ##
    # The human‐readable display label for the property.
    attribute :display_label, Valkyrie::Types::Coercible::String

    ##
    # The human‐readable definition for the property.
    attribute :definition,
      Valkyrie::Types::Coercible::String.optional.default(nil)

    ##
    # The human‐readable usage guidelines for the property.
    attribute :usage_guidelines,
      Valkyrie::Types::Coercible::String.optional.default(nil)

    ##
    # An advisory label as to whether the property is required, optional, etc.
    #
    # This describes the property from a best‐practices standpoint; normatively,
    # its obligation is defined by its cardinality class (below).
    attribute :requirement,
      Valkyrie::Types::Coercible::String.optional.default(nil)

    ##
    # Resource types the property should be available on. These correspond to
    # conceptual “classes” in M3, but aren’t necessarily actual Ruby classes.
    attribute :available_on, Valkyrie::Types::Set.of(
      Valkyrie::Types::Coercible::Symbol
    )

    ##
    # The RDF datatype of the property.
    #
    # If multiple values are provided, they are treated as a union, not an
    # intersection.
    attribute :data_type, Valkyrie::Types::Set.of(
      Valkyrie::Types.Instance(RDF::Vocabulary::Term)
    ).default([RDF::XSD.string])

    ##
    # How to index the property.
    #
    # These correlate with the Hyrda Solr suffixes as follows:
    #
    # - displayable: _tsm
    # - facetable: _tim
    # - searchable: _*im
    # - sortable: _*i
    # - stored_searchable: _*sim
    # - stored_sortable: _tsi (why is the typing different from sortable??)
    # - symbol: _tsim
    # - fulltext_searchable: _tsimv
    #
    # The above definitions are taken from the Houndstooth documentation. We may
    # need to adjust them or add new ones.
    attribute :indexing, Valkyrie::Types::Set.of(
      Valkyrie::Types::Coercible::Symbol.enum(
        :displayable, :facetable, :searchable, :sortable, :stored_searchable,
        :stored_sortable, :symbol, :fulltext_searchable
      )
    ).default { [] }

    ##
    # A mapping of schema IRI’s to IRI’s for corresponding properties in that
    # schema.
    #
    # Property IRI’s are **not** necessarily namespaced to schema IRI’s; for
    # example DPLA and OAI‐PMH schemas both use Dublin Core properties.
    #
    # The same property may map to multiple IRIs within a given schema.
    #
    # Presently, IRI’s aren’t actually a part of the Houndstooth model (it just
    # uses prefix names), but they’re a little more reliable so we’re using
    # them!
    attribute :mapping, Valkyrie::Types::Hash.map(
      Valkyrie::Types::String,
      Valkyrie::Types::Set.of(Valkyrie::Types::String)
    ).default { {} }

    ##
    # Additional validations to run on the property.
    #
    # The following are defined:
    #
    # - match_regex: A regular expression pattern which each value must match to
    #   be valid.
    attribute :validations, Valkyrie::Types::Hash.schema(
      match_regex?: Valkyrie::Types::Coercible::String
    ).default { {} }

    # § ADDITIONAL ATTRIBUTES ##################################################

    ##
    # The cardinality class of the property.
    attribute :cardinality_class,
      Valkyrie::Types::Coercible::Symbol.default(:zero_or_more).enum(
        :zero_or_one,
        :exactly_one,
        :one_or_more,
        :zero_or_more
      )

    ##
    # A freeform space to store extra property information which isn’t covered
    # by the above.
    attribute :extra_qualities, Valkyrie::Types::Hash.map(
      Valkyrie::Types::Coercible::Symbol, Valkyrie::Types::Any
    ).default { {} }

    ##
    # Whether to run validations on this property.
    attribute :will_validate, Valkyrie::Types::Strict::Bool.default(false)

    # § METHOD DEFINITIONS #####################################################

    ##
    # Returns whether the property is available on the provided availability.
    #
    # @param availability [Symbol]
    # @return [Boolean]
    def available_on?(availability)
      available_on.include?(availability)
    end

    ##
    # The Solr indices corresponding to the requested indexing for the property.
    #
    # See <https://github.com/samvera/hydra-head/wiki/Solr-Schema> for the
    # meaning of these suffixes.
    def indices
      indexing.map { |index_kind|
        (
          name.to_s + {
            displayable: "_tsm",
            facetable: "_tim",
            searchable: "_#{solr_type_letter}im",
            sortable: "_#{solr_type_letter}i",
            stored_searchable: "_#{solr_type_letter}sim",
            stored_sortable: "_tsi",
            symbol: "_tsim",
            fulltext_searchable: "_tsimv"
          }.fetch(index_kind, "")
        ).to_sym
      }.filter { |index| index != name }
    end

    ##
    # Returns a Set of IRI’s that this property maps to in the provided schema.
    #
    # If this property has no mapping in the provided schema, the result will be
    # the empty set.
    #
    # @param schema_iri [String]
    # @return [Valkyrie::Types::Set]
    def mappings_for(schema_iri)
      mapping.fetch(schema_iri, Set.new)
    end

    private

    ##
    # The abbreviation corresponding to the Solr field type for this value.
    #
    # Do we need to support values other than string? How exactly does this
    # work?
    def solr_type_letter
      "s"
    end
  end
end
