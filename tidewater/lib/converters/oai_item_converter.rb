# frozen_string_literal: true

require_relative "concerns/oai_base"

module Converters
  ##
  # Convert attributes for OAI-PMH item.
  class OaiItemConverter
    include Converters::OaiBase

    # Delimit multiple values field with U+FFFF and tagged value with U+FFFE.
    #
    # @param val [JSON] the value(s) of a field
    # @return [string] delimited field value
    def self.field_value_from_json(val)
      if val.is_a?(Array)
        val.map { |v| field_value_from_json(v) }.join("\uFFFF")
      elsif val.is_a?(Hash)
        "#{sanitize_value(val["@value"])}\uFFFE#{val["@language"]}"
      else
        sanitize_value(val)
      end
    end

    # Convert JSON from Comet metadata API to OaiItem.
    #
    # @param resouce_uri [String] the resource URL from Comet message broker
    # @param json [JSON] the object metadata in JSON format
    # @return [OaiItem] delimited field value
    def self.from_json(resource_uri, json)
      attrs = JSON.parse(json)
      resource_id = attrs["@id"]
      raise ArgumentError.new("Inconsistent @id #{resource_id} and resource URL #{resource_uri}!") if resource_uri.nil? || !resource_uri.include?(resource_id)

      {}.tap do |pro|
        pro["source_iri"] = resource_id
        attrs.each { |k, v| pro[k] = field_value_from_json(v) if dc_elements.include? k.to_sym }
      end
    end
  end
end
