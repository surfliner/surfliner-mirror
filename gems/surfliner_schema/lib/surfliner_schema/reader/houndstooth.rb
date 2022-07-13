# frozen_string_literal: true

require "surfliner_schema/property"
require "valkyrie"

module SurflinerSchema
  module Reader
    ##
    # A reader for a Houndstooth/M3 YAML schema.
    class Houndstooth < Base
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
            mapping: config.fetch("mapping", {}).filter_map { |prefix, value|
              # `iri` is a non‐standard property and may change but let’s go
              # with it for now.
              expansion = houndstooth.dig("mappings", prefix, "iri")
              result = value.respond_to?(:to_a) ? value.to_a : [value]
              next unless expansion && result.size
              [expansion, result]
            }.to_h,
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
            extra_qualities: {} # TK: form stuff, ⁊c…
          )
        end
      end

      ##
      # A hash mapping properties to their definitions.
      #
      # @param availability [Symbol]
      # @return [{Symbol => SurflinerSchema::Property}]
      def properties(availability:)
        @properties.filter { |_name, prop| prop.available_on?(availability) }
      end
    end
  end
end
