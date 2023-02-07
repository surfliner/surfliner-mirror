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
      # A hash mapping IRIs (corresponding to M3 +range+s) to the
      # +Valkyrie::Resource+ classes which should be used to implement them.
      #
      # The default implementation just returns the default set for the reader
      # class.
      #
      # @return [{String => Class}]
      def supported_ranges
        self.class.default_supported_ranges
      end

      ##
      # A hash mapping conceptual resource “class” names to their definitions.
      #
      # @return [{Symbol => SurflinerSchema::ResourceClass}]
      def resource_classes
        {}
      end

      ##
      # A hash mapping section names to their definitions.
      #
      # @return [{Symbol => SurflinerSchema::Section}]
      def sections
        {}
      end

      ##
      # A hash mapping grouping names to their definitions.
      #
      # @return [{Symbol => SurflinerSchema::Grouping}]
      def groupings
        {}
      end

      ##
      # A hash mapping mapping names to their definitions.
      #
      # @return [{Symbol => SurflinerSchema::Mapping}]
      def mappings
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
      # The datatype of the resulting `RDF::Literal` will be the same as that
      # defined in the schema.
      #
      # @param availability [Symbol]
      # @return [{Symbol => Object}]
      def to_struct_attributes(availability:)
        properties(availability: availability).transform_values { |property|
          if property.range != RDF::RDFS.Literal
            range = property.range.to_s
            if supported_ranges.key?(range)
              Valkyrie::Types::Set.of(supported_ranges[range])
            else
              raise(
                Error::UnknownRange,
                "The range '#{range}' on #{property.name} is not recognized."
              )
            end
          else
            Valkyrie::Types::Set.of(
              Valkyrie::Types.Constructor(RDF::Literal) { |value|
                RDF::Literal.new(value, datatype: property.data_type)
              }
            )
          end
        }
      end

      ##
      # A hash mapping attributes to their form definitions.
      #
      # The base definition for this method just gives each property the default
      # form options.
      #
      # @param availability [Symbol]
      # @return [{Symbol => FormDefinition}]
      def form_definitions(availability:)
        properties(availability: availability).transform_values do |property|
          FormDefinition.new(property: property)
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
        end
      end

      ##
      # A hash mapping IRIs (corresponding to M3 +range+s) to the
      # +Valkyrie::Resource+ classes which should be used to implement them.
      #
      # This method provides the default value; individual readers may provide
      # additional mappings in the future.
      #
      # @return [{String => Class}]
      def self.default_supported_ranges
        {} # empty for now
      end

      ##
      # Formats the provided name for display, as a fallback when no display
      # label is provided.
      def self.format_name(name)
        name.to_s.gsub(/(\A|_)(.)/) {
          $1 == "_" ? " #{$2.capitalize}" : $2.capitalize
        }
      end
    end
  end
end
