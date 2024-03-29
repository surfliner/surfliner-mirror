# frozen_string_literal: true

# wrap riiif config in to_prepare to ensure its properly loaded in sidekiq workers
ActiveSupport::Reloader.to_prepare do
  if ENV["S3_BUCKET_NAME"].present?
    Riiif::Image.file_resolver = Riiif::HTTPFileResolver.new

    # @param [#to_s] id the ID of a Spotlight::FeaturedImage
    Riiif::Image.file_resolver.id_to_uri = lambda do |id|
      featured_image = Spotlight::FeaturedImage.find(id)
      aws_file = featured_image.image.file

      raise Riiif::ImageNotFoundError, "unable to find file for Spotlight::FeaturedImage #{id}" if aws_file.nil?

      aws_file.file.presigned_url("get")
    end
  else
    Riiif::Image.file_resolver = Spotlight::CarrierwaveFileResolver.new
  end

  # Riiif::Image.authorization_service = IIIFAuthorizationService

  # Riiif.not_found_image = 'app/assets/images/us_404.svg'
  #
  Riiif::Engine.config.cache_duration_in_days = 365
end
