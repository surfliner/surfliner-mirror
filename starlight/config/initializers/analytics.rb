# Setup Google Analytics in production environment
if Rails.env.production?
  Spotlight::Engine.config.ga_pkcs12_key_path = Rails.application.secrets.ga_pkcs12_key_path
  Spotlight::Engine.config.ga_web_property_id = Rails.application.secrets.ga_web_property_id
  Spotlight::Engine.config.ga_email = Rails.application.secrets.ga_email
end
