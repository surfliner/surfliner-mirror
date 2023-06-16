# frozen_string_literal: true

require "shrine/storage/s3"
require "valkyrie/storage/shrine"
require "valkyrie/shrine/checksum/s3"

# skip much of this setup if we're just building the app image
building = (ENV["DB_ADAPTER"] == "nulldb")

if building
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
  # These values can come from a variety of ENV vars
  shrine_s3_options = {
    bucket: S3Configurations::Default.bucket,
    region: S3Configurations::Default.region,
    access_key_id: S3Configurations::Default.access_key,
    secret_access_key: S3Configurations::Default.secret_key
  }

  if S3Configurations::Default.minio?
    shrine_s3_options[:endpoint] = S3Configurations::Default.endpoint
    shrine_s3_options[:force_path_style] = true
  end

  Valkyrie::StorageAdapter.register(
    Valkyrie::Storage::Shrine.new(Shrine::Storage::S3.new(**shrine_s3_options)),
    :repository_s3
  )

  Valkyrie.config.storage_adapter = :repository_s3
end

Valkyrie.config.resource_class_resolver = ::SchemaLoader.new.resource_class_resolver
Valkyrie.config.metadata_adapter = :comet_metadata_store
Hyrax.query_service.instance_variable_set(:@id_type, :bigint)
Valkyrie::IndexingAdapter.register(CometIndexingAdapter.new, :comet_index)
Hyrax::ValkyrieCanCanAdapter # just load this to make sure cancancan finds it
