# frozen_string_literal: true

module SurflinerSchema
  ##
  # A wrapper for +SurflinerSchema::Property+ which provides additional form
  # information.
  #
  # Because this is defined as a +Delegator+, all property fields are available
  # directly on the form definition as methods.
  class FormDefinition < Delegator
    ##
    # The property being described.
    attr_accessor :property

    ##
    # @param property [String]
    # @param primary [Boolean]
    def initialize(property:, primary: false)
      super(property)
      @is_primary = !!primary
    end

    ##
    # Returns the object being delegated to.
    def __getobj__
      @property
    end

    ##
    # Sets the object being delegated to.
    def __setobj__(obj)
      @property = obj
    end

    ##
    # Whether the property can take multiple values.
    #
    # @return [Boolean]
    def multiple?
      [:one_or_more, :zero_or_more].include?(cardinality_class)
    end

    ##
    # Whether the property is a primary field.
    #
    # @return [Boolean]
    def primary?
      @is_primary
    end

    ##
    # Whether the property is (formally) required.
    #
    # This is more strict than the advisory +:requirement+, and derived from the
    # cardinality class of the property.
    def required?
      [:exactly_one, :one_or_more].include?(cardinality_class)
    end

    ##
    # +Dry::Schema+ constraints for this property.
    #
    # This does not include datatype information which must be supplied by the
    # reader.
    def schema_constraints
      result = {}
      result[:min_size?] = 1 if [:exactly_one, :one_or_more].include?(cardinality_class)
      result[:max_size?] = 1 if [:zero_or_one, :exactly_one].include?(cardinality_class)
      result
    end
  end
end
