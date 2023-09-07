# frozen_string_literal: true

module SurflinerSchema
  ##
  # Builds a module which provides Reform::Form fields as well as a few
  # additional useful (class) methods for form processing.
  #
  # The additional methods are :—
  #
  # [form_definition]
  #
  #   Returns a +SurflinerSchema::FormDefinition+ corresponding to the provided
  #   property name, if such a property is available through the schema on the
  #   form; otherwise, returns nil.
  #
  # [primary_division]
  #
  #   Returns a +SurflinerSchema::Division+ for the form’s availability, limited
  #   to only primary fields.
  #
  # [secondary_division]
  #
  #   Returns a +SurflinerSchema::Division+ for the form’s availability, limited
  #   to only nonprimary fields.
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
  def self.FormFields(model_class)
    SurflinerSchema::FormFields.new(model_class)
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
    attr_reader :model_class, :availability, :reader, :definitions

    ##
    # @param availability [Symbol]
    # @param loader [#properties_for]
    def initialize(model_class)
      @model_class = model_class
      @availability = model_class.availability
      @reader = model_class.reader
      @definitions = @reader.form_definitions(availability: @availability)
    end

    ##
    # @return [String]
    def inspect
      "#{self.class}(#{availability})"
    end

    private

    def included(descendant)
      super
      descendant.instance_variable_set(:@form_definitions, definitions)
      descendant.instance_variable_set(:@schema_availability, availability)
      descendant.instance_variable_set(:@schema_reader, reader)
      descendant.instance_variable_set(:@schema_model, model_class)

      class << descendant
        ##
        # Returns the +SurflinerSchema::FormDefinition+ for the provided
        # property name in the form.
        #
        # @param property_name [Symbol]
        # @return [SurflinerSchema::Division]
        def form_definition(property_name)
          @form_definitions[property_name.to_sym]
        end

        ##
        # Returns a +SurflinerSchema::Division+ containing only primary
        # properties.
        #
        # @return [SurflinerSchema::Division]
        def primary_division
          @primary_division ||= @schema_reader.class_division(availability: @schema_availability) do |property|
            @form_definitions[property.name].primary?
          end
        end

        ##
        # Returns a +SurflinerSchema::Division+ containing only nonprimary
        # properties.
        #
        # @return [SurflinerSchema::Division]
        def secondary_division
          @secondary_division ||= @schema_reader.class_division(availability: @schema_availability) do |property|
            !@form_definitions[property.name].primary?
          end
        end
      end

      definitions.each do |property_name, definition|
        if definition.range != RDF::RDFS.Literal
          # The definition points to a nested Valkyrie object.
          # TODO
        else
          # The definition points to a literal.
          descendant.property property_name, **definition.form_options
        end
        descendant.validates(property_name, presence: true) if definition.required?
      end
    end
  end
end
