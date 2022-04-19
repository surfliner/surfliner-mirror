# frozen_string_literal: true

# Set of helper methods for IIIF presentation
module IiifHelper
  def universal_viewer_base_url
    "#{request&.base_url}/#{universal_viewer_root}/uv.html"
  end

  def universal_viewer_config_url
    "#{request&.base_url}/#{universal_viewer_root}/uv-config.json"
  end

  # Fixed directory/route for vendored universal viewer in /public
  def universal_viewer_root
    "uv"
  end
end
