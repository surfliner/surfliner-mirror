module Lark
  module RecordParsers
    ##
    # A paser for JSON content input through the API.
    class JSONParser
      ##
      # @see Lark::RecordParser#parse
      def parse(input)
        JSON.parse(input.read).symbolize_keys
      end
    end
  end
end
