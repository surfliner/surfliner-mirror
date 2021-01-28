# frozen_string_literal: true

require "spotlight"

if ENV["S3_BUCKET_NAME"].present?
  CarrierWave.configure do |config|
    config.storage = :aws
    config.aws_bucket = ENV["S3_BUCKET_NAME"]
    config.aws_acl = ENV["S3_ACL"]

    config.aws_credentials = {
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
      region: ENV["AWS_REGION"],
    }

    # For Minio particulars
    if ENV["S3_ENDPOINT"]
      config.aws_credentials[:endpoint] = ENV.fetch("S3_ENDPOINT")
      config.aws_credentials[:force_path_style] = true
    end
  end
end
