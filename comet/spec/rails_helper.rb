# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!
require "support/chromium_driver.rb"

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  config.after(:each, type: :feature) do
    Capybara.reset_sessions!
    page.driver.reset!
  end

  config.include Capybara::RSpecMatchers, type: :input

  config.before(:each, type: :system) do
    Capybara.app_host = "http://#{Capybara.server_host}:#{Capybara.server_port}"

    if ENV["SKIP_SELENIUM"] == '1'
      driven_by(:rack_test)
    else
      driven_by(:selenium_standalone_chrome_headless_sandboxless)
    end
  end
end

# register a test adapter for unit tests
Valkyrie::MetadataAdapter
  .register(Valkyrie::Persistence::Memory::MetadataAdapter.new,
    :test_adapter)
