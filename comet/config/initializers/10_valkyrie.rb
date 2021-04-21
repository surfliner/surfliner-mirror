# frozen_string_literal: true

require "shrine/storage/s3"
require "valkyrie/storage/shrine"
require "valkyrie/shrine/checksum/s3"

# skip much of this setup if we're just building the app image
building = (ENV["DB_ADAPTER"] == "nulldb")

if building || Rails.env.test?
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

unless building
  shrine_s3_options = {
    bucket: ENV.fetch("REPOSITORY_S3_BUCKET") { "comet#{Rails.env}" },
    region: ENV.fetch("REPOSITORY_S3_REGION", "us-east-1"),
    access_key_id: (ENV["REPOSITORY_S3_ACCESS_KEY"] || ENV["MINIO_ACCESS_KEY"]),
    secret_access_key: (ENV["REPOSITORY_S3_SECRET_KEY"] || ENV["MINIO_SECRET_KEY"])
  }

  if ENV["MINIO_ENDPOINT"].present?
    shrine_s3_options[:endpoint] = "http://#{ENV["MINIO_ENDPOINT"]}:#{ENV.fetch("MINIO_PORT", 9000)}"
    shrine_s3_options[:force_path_style] = true
  end

  Valkyrie::StorageAdapter.register(
    Valkyrie::Storage::Shrine.new(Shrine::Storage::S3.new(**shrine_s3_options)),
    :repository_s3
  )

  Valkyrie.config.storage_adapter = :repository_s3
end

Valkyrie.config.metadata_adapter = :comet_metadata_store
Valkyrie::IndexingAdapter.register(CometIndexingAdapter.new, :comet_index)
