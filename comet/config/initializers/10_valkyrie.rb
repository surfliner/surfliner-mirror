# frozen_string_literal: true

if ENV["DB_ADAPTER"] == "nulldb" || Rails.env.test?
  Valkyrie::MetadataAdapter
    .register(Valkyrie::Persistence::Memory::MetadataAdapter.new,
      :comet_metadata_store)
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

  Valkyrie::MetadataAdapter
    .register(Valkyrie::Sequel::MetadataAdapter.new(connection: connection),
      :comet_metadata_store)
end

Valkyrie.config.metadata_adapter = :comet_metadata_store
Valkyrie::IndexingAdapter.register(CometIndexingAdapter.new, :comet_index)
