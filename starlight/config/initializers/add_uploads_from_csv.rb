# frozen_string_literal: true

require "spotlight/add_uploads_from_csv"

class Spotlight::AddUploadsFromCSV
  ##
  # Re-define the perform method so it will process an image that comes in
  # as a file as well as images that come in via a url
  def perform(csv_data, exhibit, _user)
    encoded_csv(csv_data).each do |row|
      # The CSV row must have either a url or a file
      url = row.delete("url")
      file = row.delete("file")
      next unless url.present? || file.present?

      resource = Spotlight::Resources::Upload.new(
        data: row,
        exhibit: exhibit
      )

      if url
        resource.build_upload(remote_image_url: url)
      elsif file
        full_path = Pathname.new(
          ENV["BINARY_ROOT"] || CONFIG[:binary_root]
        ).join(file)

        resource.upload = fetch_image_from_local_disk(full_path)
      end

      resource.save_and_index
    end
  end

  ##
  # Given a filepath, ensure the file exists and make a Spotlight::FeaturedImage object
  # @param file [Pathname] full path to the file to upload
  def fetch_image_from_local_disk(file)
    image = Spotlight::FeaturedImage.new
    image.image.store!(File.open(file))
    image
  end
end
