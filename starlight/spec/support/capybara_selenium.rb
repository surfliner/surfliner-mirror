# frozen_string_literal: true

require "capybara/rspec"
require "selenium-webdriver"

Capybara.server = :puma
Capybara.default_max_wait_time = 20

Capybara.register_driver :selenium_chrome_starlight do |app|
  browser_options = Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.add_argument("--headless")
    opts.add_argument("--disable-gpu") if Gem.win_platform?
    # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
    opts.add_argument("--disable-site-isolation-trials")
  end

  Capybara::Selenium::Driver.new(app, **{browser: :remote, url: ENV["SELENIUM_URL"], capabilities: browser_options})
end

Capybara.server_host = IPSocket.getaddress(Socket.gethostname)
Capybara.default_max_wait_time = ENV.fetch("CAPYBARA_WAIT_TIME", 10) # We may have a slow application, let's give it some time.

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
