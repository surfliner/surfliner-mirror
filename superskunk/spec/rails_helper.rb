# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
ENV["RAILS_ENV"] = "test"
require File.expand_path("../config/environment", __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# register/use the memory storage adapter for tests
Valkyrie::MetadataAdapter
  .register(Valkyrie::Persistence::Memory::MetadataAdapter.new, :test_adapter)

##
# Finds FileMetadata objects by #file_identifier for the memory adapter
class MemoryFindFileMetadata < Superskunk::CustomQueries::FindFileMetadata
  def find_file_metadata(file_id)
    query_service.cache.find do |_key, resource|
      Array(resource.try(:file_identifier)).include?(file_id)
    end&.last || Valkyrie::Persistence::ObjectNotFoundError
  end
end

Valkyrie::MetadataAdapter
  .find(:test_adapter)
  .query_service
  .custom_queries
  .register_query_handler(MemoryFindFileMetadata)

##
# Preload defined availabilities/resource classes
Superskunk::SchemaLoader.new.availabilities.each do |availability|
  Valkyrie.config.resource_class_resolver.call(availability)
end

RSpec.configure do |config|
  # Remove this line to enable support for ActiveRecord
  config.use_active_record = false

  # If you enable ActiveRecord support you should unncomment these lines,
  # note if you'd prefer not to run each example within a transaction, you
  # should set use_transactional_fixtures to false.
  #
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"
  # config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.before(:example, :comet_adapter) do |example|
    adapter = Valkyrie::MetadataAdapter.find(example.metadata[:comet_adapter])
    allow(Superskunk).to receive(:metadata_adapter).and_return adapter
  end

  config.after(:example) do |example|
    Superskunk.metadata_adapter.persister.wipe!
  end
end
