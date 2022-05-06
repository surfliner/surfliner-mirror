# frozen_string_literal: true

require "surfliner_schema/property"
require "valkyrie"

module SurflinerSchema
  module Reader
    ##
    # A reader for a Houndstooth/M3 YAML schema.
    class Houndstooth
      ##
      # Creates a new simple schema reader given a Houndstooth Hash.
      #
      # @param attr_config [Hash]
      def initialize(houndstooth)
        @properties = houndstooth.fetch("properties", {}).each_with_object({}) do |(name, config), dfns|
          proprety_name = name.to_sym
          dfns[proprety_name] = Property.new(
            name: proprety_name,
            available_on: config.dig("available_on", "class").to_a.map(&:to_sym),
            data_type: RDF::Vocabulary.find_term(config.fetch("data_type", "http://www.w3.org/2001/XMLSchema#string")),
            indexing: config.fetch("indexing", []).map(&:to_sym),
            cardinality_class:
              if config.dig("cardinality", "minimum").to_i > 0
                # At least one.
                if config.dig("cardinality", "maximum").to_i > 1
                  # One or more.
                  :+
                else
                  # Only one.
                  :!
                end
              else
                maximum = config.dig("cardinality", "maximum")
                if maximum.nil? || maximum > 1
                  # Zero or more (the default).
                  :*
                else
                  # Zero or one.
                  :"?"
                end
              end,
            extra_qualities: {} # TK: form stuff, mappings, ⁊c…
          )
        end
      end

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
        @properties.filter { |_name, prop| prop.available_on?(availability) }
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
            Valkyrie::Types.Instance(RDF::Literal)
          )
        }
      end

      ##
      # A hash mapping attributes to their form options.
      #
      # @param availability [Symbol]
      # @return [{Symbol => {Symbol => Object}}]
      def form_options(availability:)
        {} # TK: Form options are not currently supported in M3.
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
