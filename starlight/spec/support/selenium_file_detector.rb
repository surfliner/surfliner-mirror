# frozen_string_literal: true

# This is required to use `attach_file` with selenium in docker contexts
# see: https://github.com/teamcapybara/capybara/blob/12c065154809cc1ea075753e54b3eb51477a748a/spec/selenium_spec_chrome_remote.rb#L56-L60
# see: https://github.com/SeleniumHQ/selenium/blob/a81b559fe727c3ab4b5810bcc64da7182579c7a5/rb/lib/selenium/webdriver/common/driver_extensions/uploads_files.rb#L29-L55
def enable_selenium_file_detector
  # don't use in non-docker context
  return unless ENV["SELENIUM_URL"]

  selenium_driver = page.driver.browser
  selenium_driver.file_detector = lambda do |args|
    str = args.first.to_s
    str if File.exist?(str)
  end
end

# Setup Webmock stubbing for all image uploads via URL
def stub_http_image_uploads
  image_filename = "blake_image.jpg"
  image_file = File.read(File.join(fixture_path, image_filename))
  image_uri = "http://www.example.com/#{CGI.escape(image_filename)}"
  stub_request(:get, image_uri).to_return(body: image_file)
end
