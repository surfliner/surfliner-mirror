# frozen_string_literal: true

Riiif::Image.file_resolver = Riiif::HTTPFileResolver.new
Riiif::Image.file_resolver.id_to_uri = lambda do |id|
  IIIFHelpers.image_path(id)
end

# Riiif::Image.authorization_service = IIIFAuthorizationService

# Riiif.not_found_image = 'app/assets/images/us_404.svg'
#
Riiif::Engine.config.cache_duration_in_days = 365
