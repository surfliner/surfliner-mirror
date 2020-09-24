# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'
require 'action_mailer/railtie'
require 'geoblacklight/version'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Discovery
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified
    # here. Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.action_mailer.delivery_method = ENV.fetch('DELIVERY_METHOD', 'letter_opener_web').to_sym
    config.action_mailer.default_url_options = { host: URI.parse(ENV.fetch('APP_URL', '')).hostname,
                                                 protocol: URI.parse(ENV.fetch('APP_URL', '')).scheme }

    config.action_mailer.default_options = { from: ENV['CONTACT_EMAIL'],
                                             to: ENV['CONTACT_EMAIL'] }

    if ENV.fetch('DELIVERY_METHOD', '').eql? 'smtp'
      config.action_mailer.smtp_settings = { address: ENV['SMTP_HOST'],
                                             port: ENV['SMTP_PORT'],
                                             user_name: ENV['SMTP_USERNAME'],
                                             password: ENV['SMTP_PASSWORD'],
                                             authentication: ENV.fetch('SMTP_AUTHENTICATION', '').to_sym,
                                             enable_starttls_auto: true }
    end
  end
end
