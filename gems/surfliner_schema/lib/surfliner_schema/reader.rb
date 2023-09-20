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

    attr_reader :valkyrie_resource_class
    attr_reader :property_transform

    def initialize(valkyrie_resource_class: Valkyrie::Resource,
      property_transform: nil)
      @valkyrie_resource_class = valkyrie_resource_class
      @property_transform = property_transform
    end

    ##
    # The +SurflinerSchema::Profile+ associated with this reader.
    #
    # @return [SurflinerSchema::Profile?]
    def profile
      @profile ||= SurflinerSchema::Profile.new
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
      {}
    end

    ##
    # An array of availabilities present on this reader.
    #
    # @return [Array<Symbol>]
    def availabilities
      resource_classes.keys
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
        dry_type_for(property, availability: availability)
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
    # A +Dry::Schema+ for the given availability.
    #
    # @param availability [Symbol]
    # @return [Dry::Schema]
    def dry_schema(availability:)
      @schemas ||= {}
      return @schemas[availability] if @schemas.include?(availability)
      schema_types = to_struct_attributes(availability: availability)
      definitions = form_definitions(availability: availability)
      @schemas[availability] = Dry::Schema.Params do
        definitions.each do |property_name, definition|
          # Iterate over each property’s form definitions and add a schema
          # definition for each one.
          if definition.range != RDF::RDFS.Literal
            # The definition points to a nested Valkyrie object; we must define
            # a nested schema for it.
            nested_model = resolve(definition.range)
            required(property_name).value(schema_types[property_name],
              **definition.schema_constraints).each do
              hash(dry_schema(availability: nested_model.availability))
            end
          else
            # The definition points to a RDF literal; the datatype provides
            # any remaining validation.
            required(property_name).value(schema_types[property_name],
              **definition.schema_constraints)
          end
        end
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
    # A SurflinerSchema::Division listing the sections, groupings, and
    # properties with the provided availability.
    #
    # If a block is provided, it is used to filter the resultant properties.
    # Otherwise, every property will be included.
    #
    # @param availability [Symbol]
    # @return [SurflinerSchema::Division]
    def class_division(availability:, &block)
      if block
        filtered_class_division(availability, &block)
      else
        class_divisions[availability]
      end
    end

    ##
    # A resolver for class names which dynamically creates and defines new
    # classes as needed when accessing Valkyrie objects.
    #
    # If provided, +base_class+ will be used as the base class.
    #
    # Availabilities will always resolve to the same classes, so +base_class+
    # is ignored on subsequent calls for a given availability.
    #
    # See +SurflinerSchema::Loader#resource_class_resolver+.
    #
    # @param class_name [#to_s]
    # @return [Class]
    def resolve(class_name)
      @resolved_classes ||= {}
      resource_class = resource_class_from_name(class_name)
      return nil unless resource_class
      availability = resource_class.name
      return @resolved_classes[availability] if @resolved_classes[availability]

      camelized = availability.to_s.camelize
      struct_attributes = to_struct_attributes(availability: availability)
      reader = self
      base_class = if valkyrie_resource_class.is_a?(Proc)
        # If a +Proc+, +valkyrie_resource_class+ must be called to get the
        # class.
        valkyrie_resource_class.call(resource_class)
      else
        # If +valkyrie_resource_class+ is not a +Proc+, it is the class to be
        # used.
        valkyrie_resource_class
      end
      @resolved_classes[availability] = Class.new(base_class) do |klass|
        @availability = availability
        @class_name = camelized
        @reader = reader

        klass.attributes(struct_attributes)

        include SurflinerSchema::Mappings

        def initialize(*args, **kwargs)
          super(*args, **kwargs)
          self.internal_resource = self.class.to_s # update internal_resource
        end

        class << self
          ##
          # The “availability” symbol corresponding to this model.
          #
          # @return [Symbol]
          attr_reader :availability

          ##
          # The +SurflinerSchema::Reader+ which defined this model.
          #
          # @return [Symbol]
          attr_reader :reader

          ##
          # The Ruby class name corresponding to this model.
          #
          # @return [String]
          def to_s
            @class_name
          end
        end
      end
    end

    private

    ##
    # Coerces the provided class name to the name of an M3 conceptual “class”
    # defined on the schemas for this reader.
    #
    # @param class_name {#to_s}
    # @return {SurflinerSchema::ResourceClass?}
    def resource_class_from_name(class_name)
      resource_class = resource_classes.values.find { |resource_class|
        resource_class.name.to_s == class_name.to_s ||
          resource_class.iri && resource_class.iri.to_s == class_name.to_s
      }
      return resource_class if resource_class
      underscored = class_name.to_s.underscore.to_sym
      resource_classes[underscored]
    end

    ##
    # Returns the +Dry::Type+ for the provided property.
    #
    # @param property {SurflinerSchema::Property}
    # @return {Dry::Type}
    def dry_type_for(property, availability:)
      base_type =
        if property.range != RDF::RDFS.Literal
          begin
            dry_range(property.range)
          rescue
            raise(
              Error::UnknownRange,
              "The range #{property.range} on #{property.name} is not recognized."
            )
          end
        else
          dry_data_type(property.data_type)
        end
      Valkyrie::Types::Set.of(
        Valkyrie::Types.Constructor(base_type) { |value|
          if property_transform.nil?
            base_type[value]
          else
            base_type[property_transform.call(value, property: property, availability: availability)]
          end
        }
      )
    end

    ##
    # Returns a +Dry::Type+ for the provided range.
    #
    # This just calls out to +#resolve+ in an attempt to resolve the range
    # into a nested Valkyrie resource.
    #
    # @param range {RDF::URI}
    # @return {Valkyrie::Resource}
    def dry_range(range)
      resolved_class = resolve(range)
      raise ArgumentError unless resolved_class
      resolved_class
    end

    ##
    # Returns a +Dry::Type+ for the provided RDF datatype.
    #
    # @param data_type {RDF::URI}
    # @return {Dry::Type}
    def dry_data_type(data_type = RDF::RDFV.PlainLiteral)
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
              RDF::Literal.new(value.value, language: self.class.bcp47(value.language))
            elsif data_type == RDF::RDFV.langString
              # The provided value has no language tag, but one is required.
              # Use "und" (undetermined).
              RDF::Literal.new(value.value, language: "und")
            else
              # Use a datatype of +xsd:string+.
              RDF::Literal.new(value.value, datatype: RDF::XSD.string)
            end
          elsif data_type == RDF::XSD.language
            # The datatype is +xsd:language+; cast its value to BCP 47.
            RDF::Literal.new(self.class.bcp47(value.value), datatype: data_type)
          else
            # The datatype is not one of the above and does not support
            # language‐tagged strings.
            RDF::Literal.new(value.value, datatype: data_type)
          end
        elsif data_type == RDF::RDFV.langString
          # The datatype mandates a language tag; use "und" (undetermined).
          RDF::Literal.new(value, language: "und")
        elsif data_type == RDF::RDFV.PlainLiteral
          # This is a non–language‐tagged plain literal; use +xsd:string+ as
          # the datatype.
          RDF::Literal.new(value, datatype: RDF::XSD.string)
        elsif data_type == RDF::XSD.language
          # The datatype is +xsd:language+; cast its value to BCP 47.
          RDF::Literal.new(self.class.bcp47(value), datatype: data_type)
        else
          # The datatype is not plain and does not support language‐tagged
          # strings.
          RDF::Literal.new(value, datatype: data_type)
        end
      }
    end

    ##
    # A hash mapping M3 conceptual “class” names to SurflinerSchema::Divisions
    # which wrap the corresponding definition and contain the associated
    # properties.
    #
    # @return [{Symbol => SurflinerSchema::Division}]
    def class_divisions
      @class_divisions ||= resource_classes.keys.each_with_object({}) do |name, divs|
        divs[name] ||= filtered_class_division(name)
      end
    end

    ##
    # A +SurflinerSchema::Division+ which contains all the properties which
    # match the provided block for the given availability.
    #
    # If no block is given, every property is matched.
    #
    # @param availability [Symbol]
    # @return [SurflinerSchema::Division]
    def filtered_class_division(availability)
      div = Division.new(name: availability, kind: :class, reader: self)
      properties(availability: availability).values.each do |property|
        div << property if !block_given? || yield(property)
      end
      div
    end

    public

    ##
    # Converts the provided ISO639 tag into a BCP47 tag, or returns the tag
    # unmodified.
    def self.bcp47(langtag)
      iso = ISO_639.find_by_code(langtag.downcase)
      return langtag unless iso
      [iso.alpha2, iso.alpha3_terminologic, iso.alpha3_bibliographic].find { |code| !code.empty? }
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
    def self.for(config, schema_name: "<unknown>",
      valkyrie_resource_class: Valkyrie::Resource,
      property_transform: nil)
      if config.include? "attributes"
        ::SurflinerSchema::Reader::SimpleSchema.new(config["attributes"].transform_keys(&:to_sym),
          valkyrie_resource_class: valkyrie_resource_class,
          property_transform: property_transform)
      elsif config.fetch("m3_version", "").start_with?("1.0")
        ::SurflinerSchema::Reader::Houndstooth.new(config,
          valkyrie_resource_class: valkyrie_resource_class,
          property_transform: property_transform)
      else
        raise(
          Error::NotRecognized,
          "Schema format not recognized: #{schema_name}"
        )
      end
    end
  end
end
