# frozen_string_literal: true

module Lark
  module RecordParsers
    ##
    # A paser for JSON content input through the API.
    class JsonParser
      ##
      # @see Lark::RecordParser#parse
      def parse(input)
        data = input.is_a?(String) ? input : input.read
        json = JSON.parse(data)
        return json.map(&:symbolize_keys) if json.is_a?(Array)

        json.symbolize_keys
      rescue JSON::ParserError => e
        raise Lark::BadRequest, e.message
      end
    end
  end
end
