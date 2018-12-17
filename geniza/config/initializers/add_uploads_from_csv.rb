require 'spotlight/add_uploads_from_csv'

class Spotlight::AddUploadsFromCSV
  ##
  # Re-define the perform method so it will process an image that comes in
  # as a file as well as images that come in via a url
  def perform(csv_data, exhibit, _user)
    encoded_csv(csv_data).each do |row|
      # The CSV row must have either a url or a file
      url = row.delete('url')
      file = row.delete('file')
      next unless url.present? || file.present?

      resource = Spotlight::Resources::Upload.new(
        data: row,
        exhibit: exhibit
      )

      resource.build_upload(remote_image_url: url) if url
      resource.upload = fetch_image_from_local_disk(file) if file
      resource.save_and_index
    end
  end

  ##
  # Given a filepath, ensure the file exists and make a Spotlight::FeaturedImage object
  def fetch_image_from_local_disk(file)
    image = Spotlight::FeaturedImage.new
    import_dir = ENV['IMPORT_DIR'] || ''
    filepath = File.join(import_dir, file)
    image.image.store!(File.open(filepath))
    image
  end
end
