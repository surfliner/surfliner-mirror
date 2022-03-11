# frozen_string_literal: true

require "surfliner_schema/reader"
require "valkyrie"

module SurflinerSchema
  ##
  # Wraps readers to implement the same methods as Hyrax::SimpleSchemaLoader.
  #
  # All of these methods are provided with a `schema:` argument by Hyrax, but it
  # is ignored. Instead, the schemas specified on the readers will be used.
  class HyraxLoader
    ##
    # Creates a new HyraxLoader for the provided readers.
    #
    # @param *readers [Array<SurflinerSchema::Reader>]
    # @param availability [Symbol]
    def initialize(*readers, availability:)
      @availability = availability
      @readers = readers
    end

    ##
    # A hash mapping attributes to Valkyrie types.
    #
    # @return [{Symbol => Object}]
    def attributes_for(**_opts)
      {}.merge(
        *@readers.map { |reader|
          reader.to_struct_attributes(availability: @availability)
        }
      )
    end

    ##
    # A hash mapping attributes to their form options.
    #
    # @return [{Symbol => {Symbol => Object}}]
    def form_definitions_for(**_opts)
      {}.merge(
        *@readers.map { |reader|
          reader.form_options(availability: @availability)
        }
      )
    end

    ##
    # A hash mapping indicies to their corresponding names.
    #
    # @return [{Symbol => Symbol}]
    def index_rules_for(**_opts)
      {}.merge(
        *@readers.map { |reader|
          reader
            .indices(availability: @availability)
            .transform_values { |dfn| dfn[:name] }
        }
      )
    end

    ##
    # The (singleton) class to use when loading schemas.
    def self.loader_class
      SurflinerSchema::Loader
    end

    ##
    # Creates a new HyraxLoader for the provided schemas.
    #
    # @param *schemas [Array<Symbol>]
    # @return [SurflinerSchema::HyraxLoader]
    def self.for_schemas(*schemas, availability: :generic_object)
      new(
        *schemas.map { |schema| loader_class.instance.load(schema) },
        availability: availability
      )
    end
  end
end
