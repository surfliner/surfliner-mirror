if ENV["IIIF_BASE_URL"].present?
  module IIIFHelpers
    IIIF_BASE_URL = ENV["IIIF_BASE_URL"]

    def self.info_url(id, _options)
      "#{IIIF_BASE_URL}/#{id}/info.json"
    end

    def self.info_path(id)
      "#{IIIF_BASE_URL}/#{id}/info.json"
    end

    def self.image_path(id,
                        region: "full",
                        size: "max",
                        rotation: "0",
                        quality: "default",
                        format: "jpg")
      "#{IIIF_BASE_URL}/#{id}/#{region}/#{size}/#{rotation}/#{quality}.#{format}"
    end
  end

  Spotlight::Engine.config.iiif_url_helpers = IIIFHelpers
end
