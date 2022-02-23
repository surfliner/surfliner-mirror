module Superskunk
  def self.comet_query_service
    Valkyrie::MetadataAdapter.find(:comet_metadata_store).query_service
  end
end
