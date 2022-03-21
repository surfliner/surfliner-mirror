# frozen_string_literal: true

require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
# Prevent database truncation if the environment is production
abort("The Rails env is running in production mode!") if Rails.env.production?
require "rspec/rails"
require "rspec/its"
require "capybara"
require "factory_bot"

Dir[Rails.root.join("spec", "support", "**", "*.rb")].sort.each do |f|
  require f
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods
end
