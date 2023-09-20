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
  # @param model_class [#reader,#availability]
  #
  # @return [Module] a mixin module providing properties, validations, and
  #   implementations of the above methods for a +Reform::Form+.
  #
  # @example
  #   class MonographForm < Reform::Form
  #     include SurflinerSchema::FormFields(Monograph)
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

      ##
      # Overrides the default Reform deserialization behaviour to pass the input
      # params through Dry::Schema prior to passing them to the form.
      #
      # This will do type coercions, and also keep track of any errors.
      descendant.define_method(:deserialize!) do |params|
        contract = self.class.schema_contract.new
        keys = contract.schema.key_map.map { |key| key.name.to_sym }

        # For any params that are not in the provided hash but are in the
        # schema, add the current existing values in the form.
        schema_params = keys.each_with_object({}) do |name, obj|
          obj[name] = if params.include?(name)
            params[name]
          elsif params.include?(name.to_s)
            params[name.to_s]
          else
            self[name]
          end
        end

        # Attempt to coerce all of the params into approptiate values, and run
        # schema validations on them. This is a bit more nuanced than the
        # builtin Reform coercion support, which doesn’t have error handling.
        result = contract.call(schema_params)

        # +@result+ is defined by Reform::Contract and collects the results of
        # the validation process. +#to_results+ gives the actual used array of
        # result objects. We only bother appending to it here if the schema
        # application resulted in a failure; otherwise, it will be written to
        # by Reform during the normal validation process.
        @result.to_results << result if result.failure?

        # Replace schema params with their coerced result, persisting any
        # params which were not specified in the schema through to the form.
        (params.try(:with_indifferent_access) || params).merge(result.to_h)
      end

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

        ##
        # A +Dry::Validation::Contract+ for schema‐defined properties in this
        # form.
        #
        # By default, this just applies schema processing, but additional rules
        # can be defined with +.rule+.
        def schema_contract
          schema = @schema_reader.dry_schema(availability: @schema_availability)
          @schema_contract ||= Class.new(SurflinerSchema::Contract) do
            params(schema)
          end
        end
      end

      definitions.keys.each do |property_name|
        descendant.property property_name, default: []
      end
    end
  end
end
