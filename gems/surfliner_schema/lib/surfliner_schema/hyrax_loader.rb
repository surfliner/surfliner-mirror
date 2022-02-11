# frozen_string_literal: true

require "surfliner_schema/reader"

module SurflinerSchema
  ##
  # Wraps SurflinerSchema::Reader to implement the same methods as Hyrax::SimpleSchemaLoader.
  #
  # All of these methods are provided with a `schema:` argument by Hyrax, but it is ignored.
  # Instead, the schemas specified on the `SurflinerSchema::Reader` will be used.
  class HyraxLoader
    ##
    # Creates a new HyraxLoader for the provided Reader.
    #
    # @param [SurflinerSchema::Reader] reader
    def initialize(reader)
      @reader = reader
    end

    ##
    # A hash mapping attributes to Valkyrie types.
    #
    # Equivalent to Reader#types.
    #
    # @return [{Symbol => Dry::Types::Type}]
    def attributes_for(**_opts)
      @reader.types
    end

    ##
    # A hash mapping attributes to their form options.
    #
    # Equivalent to Reader#form_options.
    #
    # @return [{Symbol => {Symbol => Object}}]
    def form_definitions_for(**_opts)
      @reader.form_options
    end

    ##
    # A hash mapping indicies to their corresponding names.
    #
    # Compare Reader#indices.
    #
    # @return [{Symbol => Symbol}]
    def index_rules_for(**_opts)
      @reader.indices.transform_values { |dfn| dfn[:name] }
    end

    def self.reader_class
      SurflinerSchema::Reader
    end

    ##
    # Creates a new HyraxLoader for the provided schemas.
    #
    # @param [Array<Symbol>] *schemas
    # @return [SurflinerSchema::HyraxLoader]
    def self.for_schemas(*schemas)
      new(reader_class.new(*schemas))
    end
  end
end
