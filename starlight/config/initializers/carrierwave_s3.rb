# frozen_string_literal: true

require "spotlight"

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
  config.fog_provider = "fog/aws"
  config.fog_credentials = {
    provider: "AWS",
    aws_access_key_id: ENV.fetch("S3_ACCESS_KEY_ID"),
    aws_secret_access_key: ENV.fetch("S3_SECRET_ACCESS_KEY"),
    host: ENV.fetch("S3_HOST"),
    endpoint: ENV.fetch("S3_ENDPOINT"),
    path_style: true,
  }
  config.fog_directory = ENV.fetch("S3_BUCKET")
  # config.fog_public     = false # optional, defaults to true
  # config.fog_attributes = { cache_control: "public, max-age=#{365.days.to_i}" } # optional, defaults to {}
  config.storage = :fog
end
