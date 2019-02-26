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
      Capybara.server_port = 55_555
      Capybara.server_host = ip
      if ENV["TEST_APP_URL"].present?
        Capybara.app_host = ENV["TEST_APP_URL"]
      else
        # Capybara.app_host = "#{ip}:#{Capybara.server_port}"
        driven_by :selenium,
                  using: :chrome,
                  options: { browser: :remote,
                             url: ENV["SELENIUM_URL"],
                             desired_capabilities: :chrome, }
      end
    else
      driven_by :selenium_chrome_headless
    end
  end
end
