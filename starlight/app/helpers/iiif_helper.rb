# frozen_string_literal: true

# Set of helper methods for IIIF presentation
module IiifHelper
  def universal_viewer_base_url
    "#{request&.base_url}/#{universal_viewer_root}/uv.html"
  end

  def universal_viewer_config_url
    "#{request&.base_url}/#{universal_viewer_root}/uv-config.json"
  end

  # Our md-5 hashed install directory for vendored universal viewer in /public
  def universal_viewer_root
    "/uv-#{asset_thumbprint}"
  end

  # retrieve the MD5-thumbprinted name for our assets (see the rake uv:update task)
  def asset_thumbprint
    ::File.read(Rails.root.join("public", "uv", ".md5")).strip
  end
end
