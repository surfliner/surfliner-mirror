# frozen_string_literal: true

require "spotlight"

if ENV["S3_BUCKET_NAME"].present?
  module Spotlight
    class FeaturedImageUploader < CarrierWave::Uploader::Base
      # Overrides the default storage directory for S3/Minio uploads
      # If we did not do this, the file path in S3 would be <bucket>/uploads/spotlight/....
      # @return [String] Uses the image id as a folder prefix for namespacing
      # otherwise there could easily be multiple "train.jpg" files..
      def store_dir
        String(model.id)
      end
    end
  end

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
