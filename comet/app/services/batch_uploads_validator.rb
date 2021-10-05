# frozen_string_literal: true

require "yaml"

##
# This is a simple yaml config-driven schema loader
class BatchUploadsValidator
  ##
  # @param [Symbol] schema
  # @return [Array>] valid headers for batch uploads
  def self.validator_for(schema_name)
    Validator.new(schema_config(schema_name))
  end

  ##
  # @api private
  class Validator
    attr_reader :headers

    ##
    # @param [Hash<String, Object>] config
    def initialize(config)
      @headers = config["headers"]
    end

    def invalid_headers(row)
      [].tap do |p|
        row.keys.each do |k|
          p << k unless headers.include?(k)
        end
      end
    end
  end

  ##
  # @param [#to_s] schema_name
  # @return [Hash]
  def self.schema_config(schema_name)
    YAML.load_file(File.expand_path("../../config/metadata/#{schema_name}.yaml", __dir__))
  end
end
