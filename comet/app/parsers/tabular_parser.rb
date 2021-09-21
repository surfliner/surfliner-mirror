# frozen_string_literal: true

require_relative "tabular_parsers/csv_parser"

##
# @abstract A parser for batch upload source file. Implementing classes
#   should provide `#parse(file)`
class TabularParser
  ##
  # @param content_type [String]
  # @return [#parse]
  def self.for(content_type:)
    case content_type
    when "text/csv"
      TabularParsers::CSVParser.new
    else
      raise "Unsupported data source type: #{content_type}"
    end
  end

  ##
  # @param file [#read]
  # @return []
  def parse(_file)
    raise NotImplementedError
  end
end
