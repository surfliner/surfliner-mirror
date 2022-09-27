# frozen_string_literal: true

module SurflinerSchema
  ##
  # Builds a module which provides a +:mapped_to+ method to +Valkyrie::Resource+
  # models.
  #
  # +:mapped_to+ takes a schema IRI and returns a hash of properties used by
  # that schema and a corresponding set of values from the model it is called
  # on.
  #
  # @param availability [Symbol]
  # @param loader [#property_mappings_for]
  #
  # @return [Module] a mixin module providing an implementation of `mapped_to`
  #   for a +Valkyrie::Resource+.
  #
  # @example
  #   class Monograph < Valkyrie::Resource
  #     include SurflinerSchema::Mappings(:book, loader: MySchemaLoader.new)
  #   end
  def self.Mappings(availability, **options)
    SurflinerSchema::Mappings.new(availability, **options)
  end

  ##
  # @api private
  #
  # A module providing a `mapped_to` method.
  #
  # This class provides the internals for the recommended module builder syntax:
  # +SurflinerSchema::Mappings(:my_schema_name)+.
  #
  # @see .Mappings
  class Mappings < Module
    ##
    # @param availability [Symbol]
    # @param loader [#properties_for]
    def initialize(availability, loader:)
      @availability = availability

      define_method(:mapped_to) do |schema_iri|
        loader.property_mappings_for(
          availability,
          schema_iri: schema_iri
        ).each_with_object({}) do |(name, mappings), result|
          # Ιterate over each property and define its mappings.
          value = public_send(name)
          mappings.each do |property_iri|
            # For each mapping, add the value of the property to the result.
            #
            # Properties may have multiple values.
            name_s = name.to_s
            result[name_s] ||= {}
            result[name_s][:property_iri] = property_iri
            result[name_s][:value] ||= Set.new
            result[name_s][:value].merge(
              value.respond_to?(:to_a) ? value.to_a : [value]
            )
          end
          result
        end
      end
    end

    ##
    # @return [String]
    def inspect
      "#{self.class}(#{@availability})"
    end
  end
end
