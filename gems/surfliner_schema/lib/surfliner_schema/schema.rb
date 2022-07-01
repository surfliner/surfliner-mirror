# frozen_string_literal: true

module SurflinerSchema
  ##
  # Builds a schema module for +Valkyrie::Resource+ models.
  #
  # @param availability [Symbol]
  # @param loader [#struct_attributes_for]
  #
  # @return [Module] a mixin module providing attributes for a
  #   +Valkyrie::Resource+.
  #
  # @example
  #   class Monograph < Valkyrie::Resource
  #     include SurflinerSchema::Schema(:book, loader: MySchemaLoader.new)
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
  # +SurflinerSchema::Schema(:my_availability)+
  #
  # @see .Schema
  class Schema < Module
    ##
    # @param availability [Symbol]
    # @param loader [#struct_attributes_for]
    def initialize(availability, loader:)
      @availability = availability
      @loader = loader
    end

    ##
    # @return [Hash{Symbol => Dry::Types::Type}]
    def attributes
      @loader.struct_attributes_for(@availability)
    end

    ##
    # @return [String]
    def inspect
      "#{self.class}(#{@availability})"
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
