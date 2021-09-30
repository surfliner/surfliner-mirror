# This file is copied to spec/ when you run 'rails generate rspec:install'
require_relative "../config/application"
Rails.application.load_tasks

require "spec_helper"

ENV["RAILS_ENV"] ||= "test"
ENV["DATABASE_URL"] = ENV["DATABASE_TEST_URL"] ||
  ENV["DATABASE_URL"].gsub("hyrax?pool", "hyrax-test?pool")

ENV["SOLR_URL"] = ENV["SOLR_TEST_URL"] if ENV["SOLR_TEST_URL"]

require File.expand_path("../config/environment", __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!
Dir[Rails.root.join("spec", "support", "**", "*.rb")].sort.each { |f| require f }

begin
  db_config = ActiveRecord::Base.configurations[ENV["RAILS_ENV"]]
  ActiveRecord::Tasks::DatabaseTasks.create(db_config)
  ActiveRecord::Migrator.migrations_paths = [Pathname.new(ENV["RAILS_ROOT"]).join("db", "migrate").to_s]
  ActiveRecord::Tasks::DatabaseTasks.migrate
  ActiveRecord::Base.descendants.each(&:reset_column_information)
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

# register a test adapter for unit tests
Valkyrie::MetadataAdapter
  .register(Valkyrie::Persistence::Memory::MetadataAdapter.new,
    :test_adapter)

query_registration_target =
  Valkyrie::MetadataAdapter.find(:test_adapter).query_service.custom_queries
[Hyrax::CustomQueries::Navigators::CollectionMembers,
  Hyrax::CustomQueries::Navigators::ChildFilesetsNavigator,
  Hyrax::CustomQueries::Navigators::ChildWorksNavigator,
  Hyrax::CustomQueries::FindAccessControl,
  Hyrax::CustomQueries::FindCollectionsByType,
  Hyrax::CustomQueries::FindManyByAlternateIds,
  Hyrax::CustomQueries::FindIdsByModel,
  Hyrax::CustomQueries::FindFileMetadata,
  Hyrax::CustomQueries::Navigators::FindFiles].each do |handler|
  query_registration_target.register_query_handler(handler)
end

# register/use the memory storage adapter for tests
Valkyrie::StorageAdapter
  .register(Valkyrie::Storage::Memory.new,
    :memory)

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  config.after(:each, type: :system) do
    Capybara.reset_sessions!
    page.driver.reset!
  end

  config.before(:each, type: :system) do
    Hyrax.index_adapter.wipe!
  end

  config.around(:example, :metadata_adapter) do |example|
    Valkyrie.config.metadata_adapter = example.metadata[:metadata_adapter]
    example.run
    Valkyrie.config.metadata_adapter = :comet_metadata_store
  end

  config.around(:example, :storage_adapter) do |example|
    Valkyrie.config.storage_adapter = example.metadata[:storage_adapter]
    example.run
    Valkyrie.config.storage_adapter = :repository_s3
  end

  config.include Capybara::RSpecMatchers, type: :input
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :system

  config.before(:each, type: :system) do
    Capybara.app_host = "http://#{Capybara.server_host}:#{Capybara.server_port}"

    if ENV["SKIP_SELENIUM"].present?
      driven_by(:rack_test)
    else
      driven_by(:selenium_standalone_chrome_headless_sandboxless)
    end
  end
end
