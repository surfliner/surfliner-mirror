module Hyrax
  module Renderers
    class SchemaPropertyAttributeRenderer < AttributeRenderer
      ##
      # The label for the property.
      def label
        if options&.key?(:label)
          options.fetch(:label)
        else
          property.display_label
        end
      end

      private

      ##
      # Render schema metadata for the provided value (a model).
      def attribute_value_to_html(value)
        # This is a very minimal implementation which we will probably want to
        # expand.
        li_value(value.to_s.html_safe)
      end

      ##
      # The SurflinerSchema::Property which describes this value.
      def property
        options[:property_definition]
      end
    end
  end
end
