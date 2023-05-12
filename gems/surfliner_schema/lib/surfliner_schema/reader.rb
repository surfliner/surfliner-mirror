# frozen_string_literal: true

module SurflinerSchema
  class Reader
    module Error
      autoload :DuplicateProperty, "surfliner_schema/reader/error/duplicate_property"
      autoload :NotRecognized, "surfliner_schema/reader/error/not_recognized"
      autoload :UndefinedSchema, "surfliner_schema/reader/error/undefined_schema"
      autoload :UnknownRange, "surfliner_schema/reader/error/unknown_range"
    end

    autoload :Houndstooth, "surfliner_schema/reader/houndstooth"
    autoload :SimpleSchema, "surfliner_schema/reader/simple_schema"

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
          begin
            self.class.dry_range(property.range)
          rescue
            raise(
              Error::UnknownRange,
              "The range #{property.range} on #{property.name} is not recognized."
            )
          end
        else
          self.class.dry_data_type(property.data_type)
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
    # Returns a +Dry::Type+ for the provided range.
    #
    # This just calls out to +Valkyrie.config.resource_class_resolver+ to
    # attempt to resolve the range into a nested Valkyrie resource.
    def self.dry_range(range)
      Valkyrie::Types::Set.of(
        Valkyrie.config.resource_class_resolver.call(range)
      )
    end

    ##
    # Returns a Dry::Type for the provided RDF datatype.
    def self.dry_data_type(data_type = RDF::RDFV.PlainLiteral)
      Valkyrie::Types::Set.of(
        Valkyrie::Types.Constructor(RDF::Literal) { |value|
          if value.is_a?(RDF::Literal)
            # If the provided value is already an RDF::Literal, preserve
            # the lexical value but change the datatype.
            #
            # This differs from both the default behaviour of
            # +RDF::Literal+ (which simply returns its argument) and
            # +RDF::Literal.new+ (which may cast the literal to another
            # kind of value, erasing the original lexical value).
            if data_type == RDF::RDFV.PlainLiteral ||
              data_type == RDF::RDFV.langString
              # The datatype supports language‐tagged strings.
              if value.language?
                # The provided value is tagged with a language tag.
                RDF::Literal.new(value.value, language: value.language)
              elsif data_type == RDF::RDFV.langString
                # The provided value has no language tag, but one is required.
                # Use "und" (undetermined).
                RDF::Literal.new(value.value, language: "und")
              else
                # Use a datatype of +xsd:string+.
                RDF::Literal.new(value.value, datatype: RDF::XSD.string)
              end
            else
              # The datatype is not plain and does not support language‐tagged
              # strings.
              RDF::Literal.new(value.value, datatype: data_type)
            end
          elsif data_type == RDF::RDFV.langString
            # The datatype mandates a language tag; use "und" (undetermined).
            RDF::Literal.new(value, language: "und")
          elsif data_type == RDF::RDFV.PlainLiteral
            # This is a non–language‐tagged plain literal; use +xsd:string+ as
            # the datatype.
            RDF::Literal.new(value, datatype: RDF::XSD.string)
          else
            # The datatype is not plain and does not support language‐tagged
            # strings.
            RDF::Literal.new(value, datatype: data_type)
          end
        }
      )
    end

    ##
    # Formats the provided name for display, as a fallback when no display
    # label is provided.
    def self.format_name(name)
      name.to_s.gsub(/(\A|_)(.)/) {
        $1 == "_" ? " #{$2.capitalize}" : $2.capitalize
      }
    end

    ##
    # Returns a new +SurflinerSchema::Reader+ resulting from reading the
    # provided config.
    def self.for(config, schema_name: "<unknown>")
      if config.include? "attributes"
        ::SurflinerSchema::Reader::SimpleSchema.new(config["attributes"].transform_keys(&:to_sym))
      elsif config.fetch("m3_version", "").start_with?("1.0")
        ::SurflinerSchema::Reader::Houndstooth.new(config)
      else
        raise(
          Error::NotRecognized,
          "Schema format not recognized: #{schema_name}"
        )
      end
    end
  end
end
