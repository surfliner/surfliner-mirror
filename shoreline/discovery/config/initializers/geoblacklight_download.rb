# frozen_string_literal: true

module Geoblacklight
  class Download
    def self.file_path
      ENV['GEOBLACKLIGHT_DOWNLOAD_PATH'] || "#{Rails.root}/tmp/cache/downloads"
    end
  end
end
