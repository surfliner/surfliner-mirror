# frozen_string_literal: true

module Lark
  module RecordSerializers
    ##
    # A serializer for JSON content input through the API.
    class JsonSerializer < Lark::RecordSerializer
      ##
      # @see Lark::RecordSerializer#serialize
      def serialize(record:)
        reserved_attributes = record.class.reserved_attributes
        record.attributes
          .except(*reserved_attributes)
          .transform_values { |v| serialize_labels(v) }
          .merge(id: record.id.to_s)
          .to_json
      end

      private

      def serialize_labels(values)
        return serialize_labels([values]) unless values.is_a?(Array)
        values.map { |value|
          if value.is_a?(Label)
            attrs = value.schema_attributes
            if attrs.all? { |(key, vals)| key == :literal_form && vals.size == 1 || vals.blank? }
              # The label consists only of a single +literal_form+.
              val = attrs[:literal_form].first
              val.language? ? val.to_json : val.to_s
            else
              # The label is qualified in some manner.
              attrs.transform_values do |vals|
                vals.map { |val| (val.data_type == RDF::XSD.string) ? val.to_s : val }
              end
            end
          else
            value
          end
        }
      end
    end
  end
end
