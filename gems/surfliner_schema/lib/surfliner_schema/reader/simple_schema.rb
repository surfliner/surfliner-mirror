# frozen_string_literal: true

require "surfliner_schema/property"
require "valkyrie"

module SurflinerSchema
  module Reader
    ##
    # A reader for a Hyrax “simple” YAML schema.
    #
    # Use `SurflinerSchema::HyraxLoader` to wrap schemas for use in Hyrax.
    class SimpleSchema
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
      def initialize(attr_config, availability: :generic_object)
        @availability = availability
        @properties = attr_config.each_with_object({}) do |(name, config), dfns|
          dfns[name] = Property.new(
            name: name,
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
              if config["multiple"] && config["required"]
                :+
              elsif config["multiple"]
                :*
              elsif config["required"]
                :!
              else
                :"?"
              end,
            extra_qualities: {
              form_options: config.fetch("form", {}).transform_keys(&:to_sym),
              index_keys: config.fetch("index_keys", []).map(&:to_sym)
            }
          )
        end
      end

      ##
      # An array of property names.
      #
      # @param availability [Symbol]
      # @return [Array<Symbol>]
      def names(availability: @availability)
        properties(availability: availability).keys
      end

      ##
      # A hash mapping properties to their definitions.
      #
      # @param availability [Symbol]
      # @return [{Symbol => SurflinerSchema::Property}]
      def properties(availability: @availability)
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
      def to_struct_attributes(availability: @availability)
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
      def form_options(availability: @availability)
        properties(availability: availability)
          .transform_values { |prop| prop[:extra_qualities][:form_options] }
          .filter { |_name, opts| opts && !opts.empty? }
      end

      ##
      # A hash mapping indices to property definitions.
      #
      # @param availability [Symbol]
      # @return [{Symbol => Object}]
      def indices(availability: @availability)
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
