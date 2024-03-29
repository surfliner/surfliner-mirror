require_relative "../../lib/superskunk/models/resource"
require_relative "../../lib/superskunk/schema_loader"

module Superskunk
  def self.comet_query_service
    metadata_adapter.query_service
  end

  def self.metadata_adapter
    @metadata_adapter ||= Valkyrie::MetadataAdapter.find(:comet_metadata_store)
  end
end
