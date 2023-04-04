# frozen_string_literal: true

require_relative "boot"

require "rails/all"
require "action_mailer/railtie"
require "geoblacklight/version"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Shoreline
  class Application < Rails::Application
    config.load_defaults 7.0

    if ENV["RAILS_LOG_TO_STDOUT"].present?
      logger = ActiveSupport::Logger.new($stdout)
      logger.formatter = config.log_formatter
      config.logger = ActiveSupport::TaggedLogging.new(logger)
    end

    # Temporarily use_yaml_unsafe_load
    # see: https://discuss.rubyonrails.org/t/cve-2022-32224-possible-rce-escalation-bug-with-serialized-columns-in-active-record/81017/1
    config.active_record.use_yaml_unsafe_load = true

    config.action_mailer.delivery_method = ENV.fetch("DELIVERY_METHOD", "letter_opener_web").to_sym
    config.action_mailer.default_url_options = {host: URI.parse(ENV.fetch("APP_URL", "")).hostname,
                                                 protocol: URI.parse(ENV.fetch("APP_URL", "")).scheme}

    config.action_mailer.default_options = {from: ENV["CONTACT_EMAIL"],
                                             to: ENV["CONTACT_EMAIL"]}

    if config.action_mailer.delivery_method == :smtp
      config.action_mailer.smtp_settings = {address: ENV["SMTP_HOST"],
                                             port: ENV["SMTP_PORT"],
                                             user_name: ENV["SMTP_USERNAME"],
                                             password: ENV["SMTP_PASSWORD"],
                                             authentication: ENV.fetch("SMTP_AUTHENTICATION", "").to_sym,
                                             enable_starttls_auto: true}
    end
  end
end
