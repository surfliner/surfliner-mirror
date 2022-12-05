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

  s3_bucket = ENV.fetch("STAGING_AREA_S3_BUCKET", "shoreline-staging-area-#{Rails.env}")

  Rails.logger.debug { "Using bucket #{s3_bucket} as the file staging area" }

  retries = 5
  begin
    Rails.application.config.staging_area_s3_handler =
      StagingAreaS3Handler.new(connection: fog_connection,
        bucket: s3_bucket,
        prefix: "")
  rescue => e
    if (retries -= 1) > 0
      Rails.logger.debug "Retrying to connect to S3 bucket #{ENV["STAGING_AREA_S3_BUCKET"]}."
      sleep(2.seconds)
      retry
    else
      Rails.logger.error { "Error connect to S3 bucket #{ENV["STAGING_AREA_S3_BUCKET"]}: #{e}" }
    end
  end
end
