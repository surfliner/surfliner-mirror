# frozen_string_literal: true

module Lark
  ##
  # @abstract A parser for input authority records. Implementing classes should
  #   provide `#parse(input)`, giving a data structure representing the input.
  #   This is the inverse of `Lark::RecordSerializer`. A parser/serializer pair
  #   with the same `content_type` should be capable of round-tripping records.
  #
  class RecordParser
    ##
    # @param content_type [String]
    #
    # @return [#parse]
    def self.for(content_type:)
      case content_type
      when "application/json", "text/csv"
        Lark::RecordParsers::JsonParser.new
      else
        raise UnsupportedMediaType, content_type
      end
    end

    ##
    # @param input [#read]
    #
    # @return [Hash<Symbol, Object>]
    def parse(_input)
      raise NotImplementedError
    end
  end
end
