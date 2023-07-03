# frozen_string_literal: true

module SurflinerSchema
  ##
  # A Valkyrie resource with SurflinerSchema extensions.
  #
  # This class is intended for use as a base class to the resource class
  # resolver.
  class Resource < Valkyrie::Resource
    ##
    # Returns whether the resource has an +rdf:value+ property.
    def terms?
      !self.class.value_property_name.nil?
    end

    ##
    # Returns the wrapped values as RDF terms, if this resource has an
    # +rdf:value+ property, and raises a +TypeError+ otherwise.
    def terms
      if !terms?
        raise TypeError, "No conversion from Resource without value property to term"
      else
        self[self.class.value_property_name].flat_map(&:terms)
      end
    end

    class << self
      ##
      # Overrides the default Dry::Struct +new+ behaviour to allow simple
      # casting from plain values to resources with an +rdf:value+ property.
      def new(arg = nil)
        if value_property_name.nil?
          super(arg)
        else
          case arg
          when Hash
            super(arg)
          when Dry::Struct
            # See +Dry::Struct::ClassInterface.new+.
            if equal?(arg.class)
              arg
            else
              super(arg.to_h)
            end
          else
            super({value_property_name => arg})
          end
        end
      end

      ##
      # The name of the first property in the schema with a +property_uri+ of
      # +rdf:value+.
      #
      # This property is set when a value is provided to the initializer.
      def value_property_name
        @value_property_name ||= reader.properties(availability: availability).find { |(name, property)|
          property.property_uri == RDF::RDFV.value
        }&.first
      end
    end
  end
end
