# frozen_string_literal: true

# Setup Webmock stubbing for all image uploads via URL
def stub_http_image_uploads
  image_filename = "blake_image.jpg"
  image_file = File.read(File.join(fixture_path, image_filename))
  image_uri = "http://www.example.com/#{CGI.escape(image_filename)}"
  stub_request(:get, image_uri).to_return(body: image_file)
end
