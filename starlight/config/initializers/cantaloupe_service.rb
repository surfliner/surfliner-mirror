# frozen_string_literal: true

require 'open-uri'
require 'ostruct'

module Starlight
  # iiif_service module for when using the built-in riiif server
  module CantaloupeService
    def self.endpoint
      @endpoint ||= ENV['IIIF_BASE_URL']
    end

    # @param [Spotlight::FeaturedImage] image
    # @return [String]
    def self.thumbnail_url(image)
      id = CGI.escape("#{image.id}/#{image.image.identifier}")
      "#{endpoint}/iiif/2/#{id}/full/!400,400/0/default.jpg"
    end

    # @param [Spotlight::FeaturedImage] image
    # @return [String]
    def self.info_url(image, _host = nil)
      id = CGI.escape("#{image.id}/#{image.image.identifier}")
      "#{endpoint}/iiif/2/#{id}/info.json"
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

      combined_id = CGI.escape("#{image.id}/#{image.image.identifier}")
      info_url = "#{ENV['IIIF_INTERNAL_BASE']}/iiif/2/#{combined_id}/info.json"

      OpenStruct.new(JSON.parse(URI.parse(info_url).open.read))
    end
  end
end
