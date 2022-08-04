# frozen_string_literal: true

module SurflinerSchema
  module Reader
    ##
    # A reader for a Hyrax “simple” YAML schema.
    class SimpleSchema < Base
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
            display_label: name.to_s.gsub(/(\A|_)(.)/) {
              $1 == "_" ? " #{$2.capitalize}" : $2.capitalize
            },
            definition: nil, # not supported in simple schema
            usage_guidelines: nil, # not supported in simple schema
            requirement: nil, # not supported in simple schema
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
      # A hash mapping properties to their definitions.
      #
      # @param availability [Symbol]
      # @return [{Symbol => SurflinerSchema::Property}]
      def properties(availability:)
        @properties.filter { |_name, prop| prop.available_on?(availability) }
      end

      ##
      # A hash mapping attributes to their form options.
      #
      # @param availability [Symbol]
      # @return [{Symbol => {Symbol => Object}}]
      def form_options(availability:)
        properties(availability: availability)
          .transform_values { |prop| prop[:extra_qualities][:form_options] }
          .filter { |_name, opts| opts && !opts.empty? }
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
