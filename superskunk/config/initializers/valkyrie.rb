##
# Finds FileMetadata objects by #file_identifier for the sequel adapter.
class FindFileMetadata
  def self.queries
    [:find_file_metadata]
  end

  def initialize(query_service:)
    @query_service = query_service
  end

  attr_reader :query_service

  def find_file_metadata(file_id)
    query_json = {file_identifier: [{id: file_id.to_s}]}.to_json
    refs = query_service.run_query(query_service.send(:find_inverse_references_query), query_json)
    refs.first || raise(Valkyrie::Persistence::ObjectNotFoundError)
  end
end

# skip much of this setup if we're just building the app image
if ENV["DB_ADAPTER"] == "nulldb"
  Valkyrie::MetadataAdapter.register(
    Valkyrie::Persistence::Memory::MetadataAdapter.new,
    :comet_metadata_store
  )
else
  database = ENV.fetch("METADATA_DATABASE_NAME", "comet_metadata")
  Rails.logger.info "Establishing connection to postgresql on: " \
                    "#{ENV["DB_HOST"]}:#{ENV["DB_PORT"]}.\n" \
                    "Using database: #{database}."
  connection = Sequel.connect(
    user: ENV["DB_USERNAME"],
    password: ENV["DB_PASSWORD"],
    host: ENV["DB_HOST"],
    port: ENV["DB_PORT"],
    database: database,
    max_connections: ENV.fetch("METADATA_DATABASE_POOL", 5),
    pool_timeout: ENV.fetch("METADATA_DATABASE_TIMEOUT", 5),
    adapter: :postgres
  )
  Valkyrie::MetadataAdapter.register(
    Valkyrie::Sequel::MetadataAdapter.new(connection: connection),
    :comet_metadata_store
  )

  Valkyrie.config.resource_class_resolver = Superskunk::SchemaLoader.new.resource_class_resolver

  Superskunk.comet_query_service.custom_queries.register_query_handler(FindFileMetadata)
end
