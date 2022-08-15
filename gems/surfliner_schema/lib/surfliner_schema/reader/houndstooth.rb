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
      # @param houndstooth [Hash]
      def initialize(houndstooth)
        # If the Houndstooth file specifies the properties as an array, convert
        # it into a hash.
        provided_properties = houndstooth.fetch("properties", {})
        properties_hash = provided_properties.is_a?(Hash) ? provided_properties
          : provided_properties.each_with_index.each_with_object({}) do |(v, i), o|
              o["_#{i}"] = v
            end

        # Likewise for mappings.
        provided_mappings = houndstooth.fetch("mappings", {})
        mappings_hash = provided_mappings.is_a?(Hash) ? provided_mappings
          : provided_mappings.each_with_index.each_with_object({}) do |(v, i), o|
              o["_#{i}"] = v
            end

        # Generate the properties.
        @properties = properties_hash.each_with_object({}) do |(name, config), dfns|
          property_name = config.fetch("name", name).to_sym
          property = Property.new(
            name: property_name,
            display_label: config.fetch(
              "display_label",
              property_name.to_s.gsub(/(\A|_)(.)/) {
                $1 == "_" ? " #{$2.capitalize}" : $2.capitalize
              }
            ),
            definition: config["definition"],
            usage_guidelines: config["usage_guidelines"],
            requirement: config["requirement"],
            available_on: config.dig("available_on").is_a?(Hash) ?
                config.dig("available_on", "class").to_a.map(&:to_sym) :
                config.dig("available_on").to_a.map(&:to_sym),
            data_type: RDF::Vocabulary.find_term(config.fetch("data_type", "http://www.w3.org/2001/XMLSchema#string")),
            indexing: config.fetch("indexing", []).to_a.map(&:to_sym),
            mapping: config.fetch("mapping", {}).to_h.filter_map { |prefix, value|
              # `iri` is a non‐standard property and may change but let’s go
              # with it for now.
              expansion = mappings_hash.find(proc { {} }) { |(name, mapping)|
                mapping.fetch("name", name) == prefix && mapping.has_key?("iri")
              }.dig(1, "iri")
              result = value.respond_to?(:to_a) ? value.to_a : [value]
              next unless expansion && result.size
              [expansion, result]
            }.to_h,
            cardinality_class:
              if config.dig("cardinality", "minimum").to_i > 0
                # At least one.
                if config.dig("cardinality", "maximum").to_i > 1
                  :one_or_more
                else
                  :exactly_one
                end
              else
                maximum = config.dig("cardinality", "maximum")
                if maximum.nil? || maximum > 1
                  :zero_or_more # the default
                else
                  :zero_or_one
                end
              end,
            extra_qualities: {} # TK: form stuff, ⁊c…
          )
          property.available_on.each do |availability|
            dfns[availability] ||= {}
            if dfns[availability].has_key?(property_name)
              raise(
                Error::DuplicateProperty,
                "Duplicate property #{property_name} on #{availability}."
              )
            end
            dfns[availability][property_name] = property
          end
        end
      end

      ##
      # A hash mapping properties to their definitions.
      #
      # @param availability [Symbol]
      # @return [{Symbol => SurflinerSchema::Property}]
      def properties(availability:)
        @properties.fetch(availability, {})
      end
    end
  end
end
