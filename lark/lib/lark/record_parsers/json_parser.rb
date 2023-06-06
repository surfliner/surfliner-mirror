# frozen_string_literal: true

module Lark
  module RecordParsers
    ##
    # A paser for JSON content input through the API.
    class JsonParser < Lark::RecordParser
      ##
      # @see Lark::RecordParser#parse
      def parse(input)
        data = input.is_a?(String) ? input : input.read
        json = JSON.parse(data)
        return json.map { |datum| process_json(datum.symbolize_keys) } if json.is_a?(Array)

        process_json(json.symbolize_keys)
      rescue JSON::ParserError => e
        raise Lark::BadRequest, e.message
      end

      private

      def process_json(data)
        data.transform_values do |value|
          if value.is_a?(Array)
            value.map { |v| process_value(v) }
          else
            process_value(value)
          end
        end
      end

      def process_value(value)
        case value
        when Hash
          if value.include?("@value")
            RDF::Literal.new(value["@value"], datatype: value["@type"], language: value["@language"])
          else
            process_json(value.symbolize_keys)
          end
        else
          lang_match = /^("[^"]*"|'[^']*')@([\w-]+)$/.match(value.to_s)
          if lang_match
            RDF::Literal.new(lang_match[1][1...-1], language: lang_match[2])
          else
            value
          end
        end
      end
    end
  end
end
