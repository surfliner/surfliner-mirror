# frozen_string_literal: true

module Lark
  module RecordParsers
    ##
    # A paser for JSON content input through the API.
    class JSONParser
      ##
      # @see Lark::RecordParser#parse
      def parse(input)
        json = JSON.parse(input.read)
        return json.map(&:symbolize_keys) if json.is_a?(Array)

        json.symbolize_keys
      end
    end
  end
end
