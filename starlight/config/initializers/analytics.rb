# frozen_string_literal: true

# Setup Google Analytics in production environment
if Rails.env.production?
  Spotlight::Engine.config.ga_pkcs12_key_path = ENV["GA_PKCS12_KEY_PATH"]
  Spotlight::Engine.config.ga_web_property_id = ENV["GA_WEB_PROPERTY_ID"]
  Spotlight::Engine.config.ga_email = ENV["GA_EMAIL"]
end
