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

    config.active_job.queue_adapter = ENV["RAILS_QUEUE"]&.to_sym

    # Always log to stdout by default
    logger = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)

    configure do
      config.middleware.delete ActiveFedora::LdpCache

      # Staging S3/Minio lookup with fog/aws for batch ingest
      fog_connection_options = {
        aws_access_key_id: ENV["REPOSITORY_S3_ACCESS_KEY"] || ENV["MINIO_ACCESS_KEY"],
        aws_secret_access_key: ENV["REPOSITORY_S3_SECRET_KEY"] || ENV["MINIO_SECRET_KEY"],
        region: ENV.fetch("REPOSITORY_S3_REGION", "us-east-1")
      }

      if ENV["MINIO_ENDPOINT"].present?
        fog_connection_options[:endpoint] = "http://#{ENV["MINIO_ENDPOINT"]}:#{ENV.fetch("MINIO_PORT", 9000)}"
        fog_connection_options[:path_style] = true
      end

      config.fog_connection_options = fog_connection_options
      # default to use S3/Minio staging
      config.s3_minio_staging_enabled = true
    end
  end
end
