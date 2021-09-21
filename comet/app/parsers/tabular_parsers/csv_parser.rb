# frozen_string_literal: true

require "csv"

module TabularParsers
  ##
  # A parser for CSV content source file input through file upload.
  class CSVParser
    ##
    # @see Comet::TabularParser#parse
    def parse(file)
      options = {headers: true, encoding: "utf-8", skip_blanks: true,
                 header_converters: lambda { |f| f.strip.downcase }, converters: lambda { |f| f ? f.strip : nil }}

      [].tap do |rows|
        CSV.foreach(file, options) do |row|
          rows << row.to_h.with_indifferent_access
        end
      end
    rescue CSV::MalformedCSVError => e
      raise e.message
    end
  end
end
