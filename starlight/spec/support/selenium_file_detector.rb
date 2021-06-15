# frozen_string_literal: true

# Setup Webmock stubbing for all image uploads via URL
def stub_http_image_uploads
  image_filename = "blake_image.jpg"
  image_file = File.read(File.join(fixture_path, image_filename))
  stub_request(:get, /blake_image.jpg/).to_return(body: image_file)
end
