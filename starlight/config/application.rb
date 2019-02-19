require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module UcsbSpotlight
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    config.action_mailer.default_url_options = { host: Rails.application.secrets.hostname }
    config.action_mailer.smtp_settings =
      YAML.safe_load(
        ERB.new(File.read(Rails.root.join("config", "smtp.yml"))).result,
        # by default #safe_load doesn't allow aliases
        # https://github.com/ruby/psych/blob/2884f7bf8d1bd6433babe6b7b8e4b6007e59af97/lib/psych.rb#L290
        [], [], true
      )[Rails.env] || {}

    config.active_job.queue_adapter = ENV['RAILS_QUEUE']&.to_sym || :inline
    config.action_mailer.default_options = { from: Rails.application.secrets.email_from_address || ENV['FROM_EMAIL'] || 'noreply@library.ucsb.edu' }
  end
end
