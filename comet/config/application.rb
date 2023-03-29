require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Comet
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    #
    # Temporarily use_yaml_unsafe_load
    # see: https://discuss.rubyonrails.org/t/cve-2022-32224-possible-rce-escalation-bug-with-serialized-columns-in-active-record/81017/1
    config.active_record.use_yaml_unsafe_load = true

    # Support for Rails Engine overrides.
    #
    # See <https://guides.rubyonrails.org/engines.html#overriding-models-and-controllers>.
    # (5.2 documentation: <https://guides.rubyonrails.org/v5.2/engines.html#overriding-models-and-controllers>)
    overrides = "#{Rails.root}/app/overrides"
    # Rails.autoloaders.main.ignore(overrides) # not needed in 5.2?
    config.to_prepare do
      Dir.glob("#{overrides}/**/*_override.rb").each do |override|
        require_dependency(override)
      end

      # Autoload EDTF literal support. Will this still be needed in Rails 6+?
      "RDF::EDTF::Literal".constantize
    end

    config.active_job.queue_adapter = ENV["RAILS_QUEUE"]&.to_sym

    # log to stdout by default
    if ActiveModel::Type::Boolean.new.cast(ENV.fetch("RAILS_LOG_TO_STDOUT", true))
      logger = ActiveSupport::Logger.new($stdout)
      logger.formatter = config.log_formatter
      config.logger = ActiveSupport::TaggedLogging.new(logger)
    end

    # default to use S3/Minio staging
    config.staging_area_s3_enabled = true

    configure do
      config.middleware.delete ActiveFedora::LdpCache
    end

    config.metadata_config_location = "config/metadata"
    config.metadata_config_schemas = ENV["METADATA_MODELS"].to_s.split(",").map(&:to_sym)

    config.metadata_api_uri_base =
      ENV.fetch("METADATA_API_URL_BASE") { "http://localhost:3000/concern/generic_objects" }

    config.feature_bulkrax =
      ActiveModel::Type::Boolean.new.cast(ENV.fetch("COMET_ENABLE_BULKRAX", false))
    config.feature_collection_publish =
      ActiveModel::Type::Boolean.new.cast(ENV.fetch("COMET_COLLECTION_PUBLISH", true))
    building = (ENV["DB_ADAPTER"] == "nulldb")
    config.use_rabbitmq =
      ActiveModel::Type::Boolean.new.cast(ENV.fetch("RABBITMQ_ENABLED", !building))
  end
end
