# frozen_string_literal: true

require "fog/aws"

# These values can come from a variety of ENV vars
aws_access_key_id = ENV.slice("REPOSITORY_S3_ACCESS_KEY",
  "MINIO_ACCESS_KEY",
  "MINIO_ROOT_USER").values.first
aws_secret_access_key = ENV.slice("REPOSITORY_S3_SECRET_KEY",
  "MINIO_SECRET_KEY",
  "MINIO_ROOT_PASSWORD").values.first

# skip this setup if just building the app image or no aws configuration
unless ENV["DB_ADAPTER"] == "nulldb" ||
    aws_access_key_id.nil? ||
    aws_secret_access_key.nil?
  Rails.logger.debug { "Connecting to S3 batch file staging area" }

  fog_connection_options = {
    aws_access_key_id: aws_access_key_id,
    aws_secret_access_key: aws_secret_access_key,
    region: ENV.fetch("REPOSITORY_S3_REGION", "us-east-1")
  }

  if ENV["MINIO_ENDPOINT"].present?
    endpoint = "#{ENV.fetch("MINIO_PROTOCOL", "http")}://#{ENV["MINIO_ENDPOINT"]}:#{ENV.fetch("MINIO_PORT", 9000)}"
    fog_connection_options[:endpoint] = endpoint
    Rails.logger.debug { "Accessing minio on #{endpoint}" }
    fog_connection_options[:path_style] = true
  end

  fog_connection = Fog::Storage.new(provider: "AWS", **fog_connection_options)
  Rails.application.config.staging_area_s3_connection = fog_connection
end
