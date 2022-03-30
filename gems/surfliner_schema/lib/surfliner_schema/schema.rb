# frozen_string_literal: true

module SurflinerSchema
  ##
  # Builds a schema module for +Valkyrie::Resource+ models.
  #
  # @param name [Symbol]
  #
  # @return [Module] a mixin module providing an implementation of a schema
  #   for +Valkyrie::Resource+.
  #
  # @example
  #   class Monograph < Valkyrie::Resource
  #     include Surfliner::Schema(:book)
  #   end
  #
  # @example with a custom schema loader
  #   class Monograph < Valkyrie::Resource
  #     include Surfliner::Schema(:book, loader: MySchemaLoader.new)
  #   end
  def self.Schema(name, **options)
    SurflinerSchema::Schema.new(name, **options)
  end

  ##
  # @api private
  #
  # a module providing a mapping from a set of attributes to a set of types (a
  # "schema"). when including this module in a +Valkyrie::Resource+ model class
  # it will add the given attributes to the model.
  #
  # this class provides the internals for the recommended module builder syntax:
  # +SurflinerSchema::Schema(:my_schema_name)+
  #
  # @see .Schema
  class Schema < Module
    ##
    # @param name [Symbol]
    # @param loader [#attributes_for]
    def initialize(name, loader: SurflinerSchema::Loader.instance)
      @name = name
      @loader = loader
    end

    ##
    # @return [Hash{Symbol => Dry::Types::Type}]
    def attributes
      @loader.attributes_for(name)
    end

    ##
    # @return [String]
    def inspect
      "#{self.class}(#{@name})"
    end

    private

    ##
    # @api private
    def included(descendant)
      super
      descendant.attributes(attributes)
    end
  end
end
