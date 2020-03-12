# frozen_string_literal: true

module Geoblacklight
  class Download
    def self.file_path
      ENV['SHORELINE_DOWNLOADS'] || "#{Rails.root}/tmp/cache/downloads"
    end
  end
end
