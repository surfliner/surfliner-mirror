# frozen_string_literal: true

module SurflinerSchema
  class Reader
    ##
    # A reader for a Hyrax “simple” YAML schema.
    class SimpleSchema < SurflinerSchema::Reader
      ##
      # Creates a new simple schema reader given an attributes configuration
      # hash.
      #
      # Hyrax’s simple schema format doesn’t have a field for specifying
      # property availability, so you need to specify it in the reader (or it
      # will default to :generic_object).
      #
      # @param attr_config [{Symbol => Hash}]
      # @param availability [Symbol]
      # @param valkyrie_resource_class [Class]
      def initialize(attr_config, availability: :generic_object,
        valkyrie_resource_class: Valkyrie::Resource,
        property_transform: nil)
        super(valkyrie_resource_class: valkyrie_resource_class,
              property_transform: property_transform)
        @availability = availability
        @properties = attr_config.each_with_object({}) do |(name, config), dfns|
          form_options = config.fetch("form", {}).transform_keys(&:to_sym)
          dfns[name] = Property.new(
            name: name,
            display_label: self.class.format_name(name),
            available_on: availability,
            data_type: self.class.rdf_type_for(config["type"]),
            indexing: config.fetch("index_keys", []).map { |index_key|
              if /_te?sm$/.match? index_key
                :displayable
              elsif /_te?im$/.match? index_key
                :facetable
              elsif /_te?si$/.match? index_key
                :stored_sortable
              elsif /_te?sim$/.match? index_key
                :symbol
              elsif /_te?simv$/.match? index_key
                :fulltext_searchable
              elsif /_.im$/.match? index_key
                :searchable
              elsif /_.i$/.match? index_key
                :sortable
              elsif /_.sim$/.match? index_key
                :stored_searchable
              end
            },
            cardinality_class:
              if form_options[:multiple] && form_options[:required]
                :one_or_more
              elsif form_options[:multiple]
                :zero_or_more
              elsif form_options[:required]
                :exactly_one
              else
                :zero_or_one
              end,
            extra_qualities: {
              form_options: form_options,
              index_keys: config.fetch("index_keys", []).map(&:to_sym)
            }
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

      ##
      # A hash mapping conceptual resource “class” names to their definitions.
      #
      # For simple schemas, the only supported class is the one corresponding to
      # the availability provided during reader initialization.
      #
      # @return [{Symbol => SurflinerSchema::ResourceClass}]
      def resource_classes
        {
          @availability => SurflinerSchema::ResourceClass.new(
            name: @availability,
            display_label: self.class.format_name(@availability)
          )
        }
      end

      ##
      # A hash mapping properties to their form definitions.
      #
      # To match upstream Hyrax behaviour, properties which don’t specify form
      # options are ignored.
      #
      # @param availability [Symbol]
      # @return [{Symbol => FormDefinition}]
      def form_definitions(availability:)
        properties(
          availability: availability
        ).each_with_object({}) do |(name, property), obj|
          opts = property[:extra_qualities][:form_options]
          next unless opts && !opts.empty?
          obj[name] = FormDefinition.new(
            property: property,
            primary: opts[:primary]
          )
        end
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
          prop[:extra_qualities][:index_keys].each { |key| hash[key] = prop }
        end
      end

      ##
      # The RDF type which corresponds to the provided type string.
      #
      # @param type_str [String]
      # @param availability [Symbol]
      # @return [RDF::Vocabulary::Term]
      def self.rdf_type_for(type_str)
        case type_str
        when "html"
          RDF.HTML
        when "id"
          RDF::XSD.string
        when "language-tagged_string"
          RDF.langString
        when "uri"
          RDF::XSD.anyURI
        when "xml"
          RDF.XMLLiteral
        else
          camel_case = type_str.split(/[-_\s]/).inject("") do |result, word|
            if result.empty?
              word
            else
              result + word.capitalize
            end
          end
          RDF::XSD[camel_case]
        end
      end
    end
  end
end
