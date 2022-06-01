# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Starlight
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    config.action_mailer.default_url_options = { host: URI.parse(ENV.fetch("APP_URL")).hostname,
                                                 protocol: URI.parse(ENV.fetch("APP_URL")).scheme, }
    config.action_mailer.delivery_method = ENV.fetch("DELIVERY_METHOD", "").to_sym

    if config.action_mailer.delivery_method == :smtp
      config.action_mailer.smtp_settings = { address: ENV.fetch("SMTP_HOST"),
                                             port: ENV.fetch("SMTP_PORT"),
                                             user_name: ENV.fetch("SMTP_USERNAME"),
                                             password: ENV.fetch("SMTP_PASSWORD"),
                                             authentication: ENV.fetch("SMTP_AUTHENTICATION").to_sym,
                                             enable_starttls_auto: true, }
    end

    config.action_mailer.default_options = { from: ENV.fetch("FROM_EMAIL", "fake@localhost") }

    if ENV["MEMCACHED_HOST"].present?
      config.action_controller.perform_caching = true
      config.cache_store = :mem_cache_store, ENV["MEMCACHED_HOST"]
    end

    if ENV["RAILS_LOG_TO_STDOUT"].present?
      logger           = ActiveSupport::Logger.new(STDOUT)
      logger.formatter = config.log_formatter
      config.logger    = ActiveSupport::TaggedLogging.new(logger)
    end
  end
end
