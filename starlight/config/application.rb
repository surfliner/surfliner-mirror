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

    # https://guides.rubyonrails.org/engines.html#overriding-models-and-controllers
    overrides = "#{Rails.root}/app/overrides"
    # for zeitwerk:
    # Rails.autoloaders.main.ignore(overrides)
    config.to_prepare do
      # for zeitwerk:
      # Dir.glob("#{overrides}/**/*_override.rb").sort.each do |override|
      #   load override
      # end
      Dir.glob("#{overrides}/**/*_override.rb").sort.each do |override|
        require_dependency(override)
      end
    end

    # Temporarily use_yaml_unsafe_load
    # see: https://discuss.rubyonrails.org/t/cve-2022-32224-possible-rce-escalation-bug-with-serialized-columns-in-active-record/81017/1
    config.active_record.use_yaml_unsafe_load = true

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

      # Use the lowest log level to ensure availability of diagnostic information
      # when problems arise.
      config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info").to_sym
    end
  end
end
