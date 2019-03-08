# frozen_string_literal: true

require 'capybara/rspec'
require 'capybara/rails'
require 'selenium-webdriver'

Capybara.server = :puma
Capybara.default_max_wait_time = 10

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end
  config.before(:each, type: :system, js: true) do
    if ENV["SELENIUM_URL"].present?
      # Capybara setup to allow for docker
      net = Socket.ip_address_list.detect(&:ipv4_private?)
      ip = net.nil? ? 'localhost' : net.ip_address

      # Get the application container's IP
      host! "http://#{ip}:#{Capybara.server_port}"

      # make test app listen to outside requests (selenium container)
      Capybara.server_host = '0.0.0.0'

      driven_by :selenium,
                using: :chrome,
                options: { browser: :remote,
                           url: ENV["SELENIUM_URL"],
                           desired_capabilities: :chrome, }
    else
      driven_by :selenium_chrome_headless
    end
  end
end
