# frozen_string_literal: true

module SurflinerSchema
  ##
  # A module providing a `mapped_to` method.
  module Mappings
    ##
    # Takes a schema IRI and returns a hash of properties used by that schema
    # and a corresponding set of values from the model it is called on.
    #
    # @param mapping [String]
    # @return [Hash]
    def mapped_to(mapping)
      self.class.reader.properties(
        availability: self.class.availability
      ).each_with_object({}) do |(name, property), result|
        # Ιterate over each property and define its mappings.
        value = public_send(name)
        property.mappings_for(mapping).each do |property_iri|
          # For each mapping, add the value of the property to the result.
          #
          # Properties may have multiple values.
          result[property_iri] ||= Set.new
          result[property_iri].merge(
            value.respond_to?(:to_a) ? value.to_a : [value]
          )
        end
        result
      end
    end
  end
end
