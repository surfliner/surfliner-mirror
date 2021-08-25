# frozen_string_literal: true

# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.
Devise.setup do |config|
  require "devise/orm/active_record"
  config.mailer_sender = ENV.fetch("CONTACT_EMAIL", "please-change-me@example.com")
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 11
  config.reconfirmable = true
  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 6..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.reset_password_within = 6.hours
  config.sign_out_via = :get

  config.pepper = "c5527ad0313b5575f8c74b6aa4dc207ed5ae220b050a014b79e7c4f2d6" \
                  "d7c02e4353f6b6dc289280f2b69ad67edf1813d4219d7014f60f320443" \
                  "554c078360a9"
end
