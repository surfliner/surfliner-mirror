# frozen_string_literal: true

require "open-uri"
require "ostruct"

module Starlight
  # iiif_service module for when using the built-in riiif server
  module CantaloupeService
    def self.endpoint
      @endpoint ||= ENV["IIIF_BASE_URL"]
    end

    def self.iiif_id(image)
      CGI.escape("starlight:#{image.id}/#{image.image.identifier}")
    end

    # @param [Spotlight::FeaturedImage] image
    # @return [String]
    def self.thumbnail_url(image)
      "#{endpoint}/iiif/2/#{iiif_id(image)}/full/!400,400/0/default.jpg"
    end

    # @param [Spotlight::FeaturedImage] image
    # @return [String]
    def self.info_url(image, _host = nil)
      "#{endpoint}/iiif/2/#{iiif_id(image)}/info.json"
    end

    # @param [Spotlight::Exhibit] exhibit
    # @param [Spotlight::FeaturedImage] image
    # @return [String]
    def self.manifest_url(exhibit, image)
      Spotlight::Engine.routes.url_helpers.manifest_exhibit_solr_document_path(exhibit, "#{exhibit.id}-#{image.id}")
    end

    # @param [String] id
    # @return [Hash]
    def self.info(id)
      image = Spotlight::FeaturedImage.find(id)
      info_url = "#{ENV["IIIF_INTERNAL_BASE"]}/iiif/2/#{iiif_id(image)}/info.json"

      OpenStruct.new(JSON.parse(URI.parse(info_url).open.read))
    end
  end
end
