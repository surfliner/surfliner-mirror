# frozen_string_literal: true

module Converters
  ##
  # Convert attributes for OAI-PMH item.
  class OaiSetConverter
    # Convert JSON from Comet metadata API to OaiSet.
    #
    # @param json [JSON] the object metadata in JSON format
    # @return [[Hash]] list of collection attributes
    def self.from_json(json)
      attrs = JSON.parse(json)

      attrs["ore:isAggregatedBy"].map do |data|
        {}.tap do |pro|
          pro["source_iri"] = data["@id"]
          pro["name"] = data["title"]
        end
      end
    end
  end
end
