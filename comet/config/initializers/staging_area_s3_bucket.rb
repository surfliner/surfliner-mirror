# frozen_string_literal: true

require "fog/aws"

# skip this setup if we're just building the app image
unless ENV["DB_ADAPTER"] == "nulldb"
  fog_connection_options = {
    aws_access_key_id: ENV["REPOSITORY_S3_ACCESS_KEY"] || ENV["MINIO_ACCESS_KEY"],
    aws_secret_access_key: ENV["REPOSITORY_S3_SECRET_KEY"] || ENV["MINIO_SECRET_KEY"],
    region: ENV.fetch("REPOSITORY_S3_REGION", "us-east-1")
  }

  if ENV["MINIO_ENDPOINT"].present?
    fog_connection_options[:endpoint] = "http://#{ENV["MINIO_ENDPOINT"]}:#{ENV.fetch("MINIO_PORT", 9000)}"
    fog_connection_options[:path_style] = true
  end

  s3_connection = Fog::Storage.new(provider: "AWS", **fog_connection_options)
  Rails.application.config.staging_area_s3_connection = s3_connection

  # Create the bucket if it doesn't exist
  s3_bucket = ENV.fetch("STAGING_AREA_S3_BUCKET", "comet-staging-area-#{Rails.env}")
  begin
    puts "-- Using staging area bucket: #{s3_bucket}"
    s3_connection.head_bucket(s3_bucket)
  rescue Excon::Error::NotFound
    puts "-- Creating buchet #{s3_bucket}"
    s3_connection.put_bucket(s3_bucket)
  end

  Rails.application.config.staging_area_s3_handler =
    StagingAreaS3Handler.new(fog_connection_options: fog_connection_options,
      bucket: s3_bucket,
      prefix: "")
end
