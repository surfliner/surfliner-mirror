# frozen_string_literal: true

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
        properties_hash = self.class.property_hash(houndstooth, :properties)
        classes_hash = self.class.property_hash(houndstooth, :classes)
        sections_hash = self.class.property_hash(houndstooth, :sections)
        groupings_hash = self.class.property_hash(houndstooth, :groupings)
        mappings_hash = self.class.property_hash(houndstooth, :mappings)

        # Generate the classes.
        @resource_classes = classes_hash.each_with_object({}) do |(name, config), dfns|
          class_name = config.fetch("name", name).to_sym
          dfns[class_name] = ResourceClass.new(
            name: class_name,
            display_label: config.fetch(
              "display_label",
              self.class.format_name(class_name)
            )
          )
        end

        # Generate the sections.
        @sections = sections_hash.each_with_object({}) do |(name, config), dfns|
          section_name = config.fetch("name", name).to_sym
          dfns[section_name] = Section.new(
            name: section_name,
            display_label: config.fetch(
              "display_label",
              self.class.format_name(section_name)
            )
          )
        end

        # Generate the groupings.
        @groupings = groupings_hash.each_with_object({}) do |(name, config), dfns|
          group_name = config.fetch("name", name).to_sym
          dfns[group_name] = Grouping.new(
            name: group_name,
            display_label: config.fetch(
              "display_label",
              self.class.format_name(group_name)
            ),
            definition: config["definition"],
            usage_guidelines: config["usage_guidelines"]
          )
        end

        # Generate the properties.
        @properties = properties_hash.each_with_object({}) do |(name, config), dfns|
          property_name = config.fetch("name", name).to_sym
          cardinality_maximum = config.dig("cardinality", "maximum")
          property = Property.new(
            name: property_name,
            display_label: config.fetch(
              "display_label",
              self.class.format_name(property_name)
            ),
            definition: config["definition"],
            usage_guidelines: config["usage_guidelines"],
            requirement: config["requirement"],
            available_on: config.dig("available_on").is_a?(Hash) ?
                config.dig("available_on", "class").to_a.map(&:to_sym) :
                config.dig("available_on").to_a.map(&:to_sym),
            section: config["section"].nil? ? nil : config["section"].to_sym,
            grouping: config["grouping"].nil? ? nil : config["grouping"].to_sym,
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
                if cardinality_maximum.nil? || cardinality_maximum.to_i > 1
                  :one_or_more
                else
                  :exactly_one
                end
              elsif cardinality_maximum.nil? || cardinality_maximum.to_i > 1
                :zero_or_more # the default
              else
                :zero_or_one
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

      ##
      # A hash mapping conceptual resource “class” names to their definitions.
      #
      # @return [{Symbol => SurflinerSchema::ResourceClass}]
      attr_reader :resource_classes

      ##
      # A hash mapping section names to their definitions.
      #
      # @return [{Symbol => SurflinerSchema::Section}]
      attr_reader :sections

      ##
      # A hash mapping grouping names to their definitions.
      #
      # @return [{Symbol => SurflinerSchema::Groupings}]
      attr_reader :groupings

      ##
      # Coerces the object corresponding to the provided property name in the
      # provided object to a hash by associating array values with keys derived
      # from their indices.
      #
      # This method assumes that the value corresponding to the provided
      # property name will either already be a Hash or else will be an Array.
      #
      # @param name [#to_s]
      # @return [Hash]
      def self.property_hash(obj, name)
        provided_object = obj.fetch(name.to_s, {})
        provided_object.is_a?(Hash) ? provided_object
          : provided_object.each_with_index.each_with_object({}) do |(v, i), o|
              o["_#{i}"] = v
            end
      end
    end
  end
end
