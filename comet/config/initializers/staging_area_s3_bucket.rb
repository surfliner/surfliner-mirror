# frozen_string_literal: true

require "fog/aws"

# If a dedicated s3 configuration is defined for the staging area, use that. Otherwise use the default s3 configuration
staging_s3_config = S3Configurations::StagingArea.minio? ? S3Configurations::StagingArea : S3Configurations::Default

# skip this setup if just building the app image or no aws configuration
unless ENV["DB_ADAPTER"] == "nulldb" ||
    staging_s3_config.access_key.nil? ||
    staging_s3_config.secret_key.nil?
  Rails.logger.debug { "Connecting to S3 batch file staging area" }

  fog_connection_options = {
    aws_access_key_id: staging_s3_config.access_key,
    aws_secret_access_key: staging_s3_config.secret_key,
    region: staging_s3_config.region
  }

  if staging_s3_config.minio?
    fog_connection_options[:endpoint] = staging_s3_config.endpoint
    Rails.logger.debug { "Accessing minio on #{staging_s3_config.endpoint}" }
    fog_connection_options[:path_style] = true
  end

  fog_connection = Fog::Storage.new(provider: "AWS", **fog_connection_options)
  Rails.application.config.staging_area_s3_connection = fog_connection

  # we always have a dedicated staging area bucket distinct from default storage
  s3_bucket = S3Configurations::StagingArea.bucket

  Rails.logger.debug { "Using bucket #{s3_bucket} as the file staging area" }

  retries = 5
  begin
    Rails.application.config.staging_area_s3_handler =
      StagingAreaS3Handler.new(connection: fog_connection,
        bucket: s3_bucket,
        prefix: "")
  rescue => e
    if (retries -= 1) > 0
      Rails.logger.debug "Retrying to connect to S3 bucket #{s3_bucket}."
      sleep(2.seconds)
      retry
    else
      Rails.logger.error { "Error connect to S3 bucket #{s3_bucket}: #{e}" }
    end
  end
end
