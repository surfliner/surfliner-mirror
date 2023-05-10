# frozen_string_literal: true

require "active_support"
require "valkyrie"
require "yaml"

module SurflinerSchema
  ##
  # The schema loader.
  class Loader
    ##
    # Initialize a new loader for the provided schema names.
    #
    # Schemas are loaded from the +config/metadata+ directory by default.
    # Override the +schema_location+ class method to adjust this.
    #
    # If no argument is provided, the +default_schemas+ class method will be
    # used as default; the anticipated common use·case is that a given
    # application will be using a predefined set of schemas (e·g specified in
    # an environment variable).
    #
    # Additional readers can be manually provided with the +additional_readers+
    # keyword argument; this is mainly useful for testing. Using the static
    # +:for_readers+ method is preferred if you don’t want from‐file schema
    # loading at all.
    #
    # @param schema_names [Array<Symbol>]
    # @param additional_readers [Array<SurflinerSchema::Reader::Base>]
    def initialize(schema_names = nil, additional_readers: [])
      @readers = (schema_names || self.class.default_schemas).map { |schema|
        SurflinerSchema::Reader.read(config_for(schema), schema_name: schema)
      }.concat(additional_readers.to_a)
    end

    ##
    # An Array of symbols corresponding to availabilities usable with this
    # Loader’s methods.
    #
    # @return [Array<Symbol>]
    def availabilities
      class_divisions.keys
    end

    ##
    # A hash mapping mapping names to their definitions.
    #
    # @return [{Symbol => SurflinerSchema::Mapping}]
    def mappings
      @mappings ||= @readers.each_with_object({}) do |reader, mappings|
        reader.mappings.each do |name, mapping|
          # If multiple readers define a mapping, only the first definition is
          # used.
          mappings[name] ||= mapping
        end
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
    def class_division_for(availability, &block)
      if block
        filtered_class_division(availability, &block)
      else
        class_divisions[availability]
      end
    end

    ##
    # A hash mapping attributes with the provided availability to their form
    # definitions.
    #
    # Not every property will necessarily be listed here. For example, in Simple
    # Schema, properties without form options are suppressed on forms.
    #
    # Form options are not a part of the M3 model, but are a Hyrax extension.
    #
    # @param availability [Symbol]
    # @return [Hash{Symbol => FormDefinitions}]
    def form_definitions_for(availability)
      {}.merge(*@readers.map { |reader|
        reader.form_definitions(availability: availability)
      })
    end

    ##
    # A hash mapping indicies with the provided availability to their
    # corresponding names.
    #
    # This method is provided for compatibility with Hyrax’s Indexer module
    # builder. The +schema+ parameter does not specify the schema file, but the
    # availability.
    #
    # @param schema [Symbol]
    # @return [{Symbol => Symbol}]
    def index_rules_for(schema:)
      {}.merge(*@readers.map { |reader|
        reader.indices(availability: schema).transform_values { |dfn|
          dfn[:name]
        }
      })
    end

    ##
    # A hash mapping property names with the provided availability to their
    # definitions.
    #
    # @param availability [Symbol]
    # @return [{Symbol => SurflinerSchema::Property}]
    def properties_for(availability)
      {}.merge(*@readers.map { |reader|
        reader.properties(availability: availability)
      })
    end

    ##
    # A hash mapping property names with the provided availability to a set of
    # mappings for the provided mapping IRI.
    #
    # @param availability [Symbol]
    # @param mapping [#to_s]
    # @return [{Symbol => Set<String>}]
    def property_mappings_for(availability, mapping:)
      {}.merge(*@readers.map { |reader|
        reader.properties(availability: availability).transform_values { |property|
          property.mappings_for(mapping)
        }
      })
    end

    ##
    # A resolver for class names which dynamically creates and defines new
    # classes as needed when accessing Valkyrie objects.
    #
    # To use, modify +Valkyrie.config.resource_class_resolver+ to point to this
    # resolver (or that of a subclass).
    #
    # @param base_class [Class?]
    # @return [Proc]
    def resource_class_resolver(base_class: nil)
      lambda do |class_name|
        availability = availability_from_name(class_name)
        return default_resource_class_resolver(class_name) if availability.nil?

        camelized = availability.to_s.camelize
        klass = camelized.safe_constantize
        return klass unless klass.nil?

        loader = self
        klass = Class.new(base_class || self.class.resource_base_class) do
          @availability = availability
          @class_name = camelized
          @loader = loader

          include SurflinerSchema::Schema(availability, loader: loader)

          # TODO: Maybe refactor this out into a service as it is not needed in
          # every situation.
          include SurflinerSchema::Mappings(availability, loader: loader)

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
            # The Ruby class name corresponding to this model.
            #
            # @return [String]
            def to_s
              @class_name
            end
          end
        end

        Object.const_set(camelized, klass)
      end
    end

    ##
    # A hash mapping property names with the provided availability to their
    # types.
    #
    # @param availability [Symbol]
    # @return [Hash{Symbol => Dry::Types::Type}]
    def struct_attributes_for(availability)
      {}.merge(*@readers.map { |reader|
        reader.to_struct_attributes(availability: availability)
      })
    end

    private

    ##
    # Coerces the provided class name to the name of an M3 conceptual “class”
    # defined on the schemas for this loader.
    #
    # @param class_name {#to_s}
    # @return {Symbol?}
    def availability_from_name(class_name)
      class_division = class_divisions.values.find { |resource_class|
        resource_class.name.to_s == class_name.to_s ||
          resource_class.iri && resource_class.iri.to_s == class_name.to_s
      }
      if class_division
        class_division.name
      else
        underscored = class_name.to_s.underscore.to_sym
        underscored if availabilities.include?(underscored)
      end
    end

    ##
    # A hash mapping M3 conceptual “class” names to SurflinerSchema::Divisions
    # which wrap the corresponding definition and contain the associated
    # properties.
    #
    # @return [{Symbol => SurflinerSchema::Division}]
    def class_divisions
      @class_divisions ||= @readers.each_with_object({}) do |reader, divs|
        reader.resource_classes.keys.each do |name|
          # If multiple readers define a class, only the first definition is
          # used to generate divisions.
          divs[name] ||= filtered_class_division(name)
        end
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
      reader = @readers.find { |reader|
        # Divisions can only support one schema per class; take the first.
        reader.resource_classes.key?(availability)
      }
      div = Division.new(name: availability, kind: :class, reader: reader)
      reader.properties(availability: availability).values.each do |property|
        div << property if !block_given? || yield(property)
      end
      div
    end

    ##
    # The configuration for the requested schema.
    #
    # @param schema {Symbol}
    # @return {Object}
    def config_for(schema)
      paths_for_schema = self.class.search_paths.flat_map do |root|
        [
          File.join(root, self.class.config_location, "#{schema}.yaml"),
          File.join(root, self.class.config_location, "#{schema}.yml")
        ]
      end
      schema_config_path = paths_for_schema.find { |path| File.exist? path }
      unless schema_config_path
        raise(
          Reader::Error::UndefinedSchema,
          "No configuration file found for schema: #{schema}"
        )
      end
      YAML.safe_load(File.open(schema_config_path), aliases: true)
    end

    ##
    # The default class resolver to use if the class is not defined in the
    # schema.
    #
    # This ideally should match the default Valkyrie behaviour.
    #
    # @param class_name {#to_s}
    def default_resource_class_resolver(class_name)
      class_name.to_s.constantize
    end

    public

    ##
    # The location at which metadata schemas can be found.
    #
    # @return [String]
    def self.config_location
      "config/metadata"
    end

    ##
    # The default schema names to load.
    #
    # @return [Array<Symbol>]
    def self.default_schemas
      []
    end

    ##
    # Returns a new +SurflinerSchema::Loader+ using the provided reader objects.
    #
    # @param readers [Array<SurflinerSchema::Reader::Base>]
    # @return [SurflinerSchema::Loader]
    def self.for_readers(readers)
      new([], additional_readers: readers)
    end

    ##
    # The base class to use for resource class generation (see
    # +.resource_class_resolver+).
    def self.resource_base_class
      Valkyrie::Resource
    end

    ##
    # The root paths from which to search for schemas.
    #
    # @return [Array<String>]
    def self.search_paths
      paths = []
      paths << Rails.root if const_defined?(:Rails) && Rails.respond_to?(:root)
      paths << Hyrax::Engine.root if const_defined?(:Hyrax) && Hyrax.const_defined?(:Engine) && Hyrax::Engine.respond_to?(:root)
      paths << Pathname.new(Dir.pwd) if paths.empty?
      paths
    end
  end
end
