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
    config.action_mailer.delivery_method = ENV.fetch('SHORELINE_DELIVERY_METHOD').to_sym

    if ENV['SHORELINE_SMTP_HOST'].present? && ENV['SHORELINE_SMTP_PORT'].present?
      config.action_mailer.smtp_settings = { address: ENV.fetch('SHORELINE_SMTP_HOST'),
                                             port: ENV.fetch('SHORELINE_SMTP_PORT') }
    end
  end
end
