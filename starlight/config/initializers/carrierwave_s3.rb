# frozen_string_literal: true

require "spotlight"

Rails.application.config.after_initialize do
  Spotlight::IiifManifestPresenter.class_eval do
    def iiif_url
      "#{ENV['IIIF_ENDPOINT']}/#{uploaded_resource.upload.id}%2f#{uploaded_resource.upload['image']}"
    end
  end

  # Get the Solr document built properly
  Spotlight::UploadSolrDocumentBuilder.class_eval do
    def add_image_dimensions(solr_hash)
      uri = URI("#{ENV['IIIF_ENDPOINT']}/#{resource.upload_id}%2f#{resource.upload['image']}/info.json")
      Net::HTTP.start(uri.host, uri.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        request = Net::HTTP::Get.new uri
        response = http.request(request)
        image_info = JSON.parse(response.body) # Net::HTTPResponse object
        solr_hash[:spotlight_full_image_width_ssm] = image_info['width']
        solr_hash[:spotlight_full_image_height_ssm] = image_info['height']
      end
    end

    def add_file_versions(solr_hash)
      url = "#{ENV['IIIF_ENDPOINT']}/#{resource.upload_id}%2f#{resource.upload['image']}/full/!400,400/0/default.jpg"
      solr_hash[Spotlight::Engine.config.thumbnail_field] = url
    end
  end

  # Set the correct iiif_tilesource so FeaturedImage#iiif_url works
  Spotlight::FeaturedImage.class_eval do
    def set_tilesource_from_uploaded_resource
      return if iiif_tilesource

      self.iiif_tilesource = "#{ENV['IIIF_ENDPOINT']}/#{id}%2f#{image.model['image']}/info.json"
      save
    end
  end
end

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
  config.fog_provider = 'fog/aws'
  config.fog_credentials = {
    provider:              'AWS',
    aws_access_key_id:     ENV.fetch('S3_ACCESS_KEY_ID'),
    aws_secret_access_key: ENV.fetch('S3_SECRET_ACCESS_KEY'),
    host:                  ENV.fetch('S3_HOST'),
    endpoint:              ENV.fetch('S3_ENDPOINT'),
    path_style: true
  }
  config.fog_directory  = ENV.fetch('S3_BUCKET')
  # config.fog_public     = false # optional, defaults to true
  # config.fog_attributes = { cache_control: "public, max-age=#{365.days.to_i}" } # optional, defaults to {}
  config.storage = :fog
end
