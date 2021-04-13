# frozen_string_literal: true

unless ENV["DB_ADAPTER"] == "nulldb" || Rails.env.test?
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
    Valkyrie::Sequel::MetadataAdapter.new(connection: connection), :comet_metadata_store
  )
end

Valkyrie::IndexingAdapter.register(CometIndexingAdapter.new, :comet_index)
