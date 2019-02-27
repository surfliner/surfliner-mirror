# frozen_string_literal: true

require_relative 'record_parsers/json_parser'

module Lark
  ##
  # @abstract A parser for input authority records. Implementing classes should
  #   provide `#parse(inupt)`, giving a data structure representing the input.
  class RecordParser
    ##
    # @param content_type [String]
    #
    # @return [#parse]
    def self.for(content_type:)
      case content_type
      when 'application/json'
        RecordParsers::JSONParser.new
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
