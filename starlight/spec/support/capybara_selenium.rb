# frozen_string_literal: true

require "capybara/rspec"
require "capybara/rails"
require "selenium-webdriver"

Capybara.server = :puma
Capybara.default_max_wait_time = 20

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end
  config.before(:each, type: :system, js: true) do
    if ENV["SELENIUM_URL"].present?
      # Capybara setup to allow for docker
      net = Socket.ip_address_list.detect(&:ipv4_private?)
      ip = net.nil? ? "localhost" : net.ip_address

      # Get the application container's IP
      host! "http://#{ip}:#{Capybara.server_port}"

      # make test app listen to outside requests (selenium container)
      Capybara.server_host = "0.0.0.0"

      capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
        chromeOptions: {
          args: %w[headless disable-gpu disable-dev-shm-usage], # preserve memory & cpu consumption
        }
      )

      driven_by :selenium,
                using: :chrome,
                options: { browser: :remote,
                           timeout: 120, # seconds
                           url: ENV["SELENIUM_URL"],
                           desired_capabilities: capabilities, }
    else
      driven_by :selenium_chrome_headless
    end
  end
end
