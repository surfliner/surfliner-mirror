# https://edgeguides.rubyonrails.org/autoloading_and_reloading_constants.html#autoloading-when-the-application-boots
# to_prepare needed to access CustomQueries:: contants
Rails.application.config.to_prepare do
  # skip much of this setup if we're just building the app image
  if ENV["DB_ADAPTER"] == "nulldb"
    Valkyrie::MetadataAdapter.register(
      Valkyrie::Persistence::Memory::MetadataAdapter.new,
      :comet_metadata_store
    )
  else
    database = ENV.fetch("POSTGRESQL_DATABASE", "comet_metadata")
    Rails.logger.info "Establishing connection to postgresql on: " \
                      "#{ENV["POSTGRESQL_HOST"]}:#{ENV["POSTGRESQL_PORT"]}.\n" \
                      "Using database: #{database}."
    connection = Sequel.connect(
      user: ENV["POSTGRESQL_USERNAME"],
      password: ENV["POSTGRESQL_PASSWORD"],
      host: ENV["POSTGRESQL_HOST"],
      port: ENV["POSTGRESQL_PORT"],
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

    [CustomQueries::FindFileMetadata,
      CustomQueries::ParentWorkNavigator].each do |handler|
      Superskunk.comet_query_service.custom_queries.register_query_handler(handler)
    end
  end
end
