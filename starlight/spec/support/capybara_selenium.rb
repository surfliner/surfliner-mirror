# frozen_string_literal: true

require "capybara/rspec"
require "selenium-webdriver"

DOWNLOAD_PATH = Rails.root.join("tmp/Downloads")

Capybara.register_driver :selenium_chrome_starlight do |app|
  browser_options = Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.add_argument("--headless")
    opts.add_argument("--disable-gpu") if Gem.win_platform?
    # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
    opts.add_argument("--disable-site-isolation-trials")
    opts.add_argument("--window-size=1440,1440")
    opts.add_argument("--enable-features=NetworkService,NetworkServiceInProcess")
    opts.add_argument("--disable-features=VizDisplayCompositor")
  end

  # Different versions of Chrome/selenium-webdriver require setting differently - just set them all
  browser_options.add_preference("download.default_directory", DOWNLOAD_PATH)
  browser_options.add_preference(:download, prompt_for_download: false, default_directory: DOWNLOAD_PATH)
  browser_options.add_preference(:browser, set_download_behavior: {behavior: "allow"})

  Capybara::Selenium::Driver.new(app, **{browser: :remote, url: ENV["SELENIUM_URL"], capabilities: browser_options})
end

Capybara.server = :puma
Capybara.server_host = IPSocket.getaddress(Socket.gethostname)
# We may have a slow application, let's give it some time.
Capybara.default_max_wait_time = ENV.fetch("CAPYBARA_WAIT_TIME", 30).to_i

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end
  config.before(:each, type: :system, js: true) do
    # Get the application container's IP
    Capybara.app_host = "http://#{Capybara.server_host}:#{Capybara.server_port}"

    driven_by(:selenium_chrome_starlight)
  end
end
