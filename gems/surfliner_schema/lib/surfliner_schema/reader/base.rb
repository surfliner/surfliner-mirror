# frozen_string_literal: true

module SurflinerSchema
  module Reader
    ##
    # The base interface for SurflinerSchema readers.
    #
    # This reader has no properties but implements all the basic reader methods.
    class Base
      ##
      # An array of property names.
      #
      # @param availability [Symbol]
      # @return [Array<Symbol>]
      def names(availability:)
        properties(availability: availability).keys
      end

      ##
      # A hash mapping properties to their definitions.
      #
      # @param availability [Symbol]
      # @return [{Symbol => SurflinerSchema::Property}]
      def properties(availability:)
        {}
      end

      ##
      # A hash mapping indices to Valkyrie types.
      #
      # The type is always a set of `RDF::Literal`s in order to preserve the
      # lexical representation (“nominal value”) of data (for example, leading
      # and trailing zeroes in numbers). When ensuring conformance to a specific
      # cardinality or XSD datatype is required, Valkyrie change set validators
      # should be used.
      #
      # @param availability [Symbol]
      # @return [{Symbol => Object}]
      def to_struct_attributes(availability:)
        properties(availability: availability).transform_values { |_prop|
          Valkyrie::Types::Set.of(
            Valkyrie::Types.Constructor(RDF::Literal)
          )
        }
      end

      ##
      # A hash mapping attributes to their form options.
      #
      # The base definition for this method just defines each property as a
      # nonprimary form field.
      #
      # @param availability [Symbol]
      # @return [{Symbol => {Symbol => Object}}]
      def form_options(availability:)
        properties(availability: availability)
          .transform_values { |prop| {primary: false} }
      end

      ##
      # A hash mapping indices to property definitions.
      #
      # @param availability [Symbol]
      # @return [{Symbol => Object}]
      def indices(availability:)
        properties(
          availability: availability
        ).each_with_object({}) do |(_name, prop), hash|
          prop.indices.each { |key| hash[key] = prop }
        end
      end
    end
  end
end
