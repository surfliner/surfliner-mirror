# frozen_string_literal: true

module SurflinerSchema
  ##
  # Builds a module which provides Reform::Form fields as well as a few
  # additional useful methods for form processing.
  #
  # The additional methods are:
  #
  # [form_definition]
  #
  #   Returns a +SurflinerSchema::FormDefinition+ corresponding to the provided
  #   property name, if such a property is available through the schema on the
  #   form; otherwise, returns nil.
  #
  # @param availability [Symbol]
  # @param loader [#form_definitions_for]
  #
  # @return [Module] a mixin module providing properties, validations, and
  #   implementations of the above methods for a +Reform::Form+.
  #
  # @example
  #   class MonographForm < Reform::Form
  #     include SurflinerSchema::FormFields(:book, loader: MySchemaLoader.new)
  #   end
  def self.FormFields(availability, **options)
    SurflinerSchema::FormFields.new(availability, **options)
  end

  ##
  # @api private
  #
  # A module providing properties, validations, and additional methods to a
  # +Reform::Form+.
  #
  # This class provides the internals for the recommended module builder syntax:
  # +SurflinerSchema::FormFields(:my_schema_name)+.
  #
  # @see .FormFields
  class FormFields < Module
    ##
    # @param availability [Symbol]
    # @param loader [#properties_for]
    def initialize(availability, loader:)
      @availability = availability
      form_definitions = loader.form_definitions_for(availability)
      @form_definitions = form_definitions

      define_method(:form_definition) do |property_name|
        form_definitions[property_name]
      end
    end

    ##
    # @return [String]
    def inspect
      "#{self.class}(#{@availability})"
    end

    private

    def included(descendant)
      super

      @form_definitions.each do |property_name, definition|
        descendant.property property_name, **definition.form_options
        descendant.validates(property_name, presence: true) if definition.required?
      end
    end
  end
end
