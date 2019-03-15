# frozen_string_literal: true

def sign_in
  visit new_user_session_path
end

def sign_out
  visit destroy_user_session_path
end

# Use integration test helpers provided by OmniAuth
# see: https://github.com/omniauth/omniauth/wiki/Integration-Testing
# @param user [User] A FactoryBot instance of a user
def omniauth_setup_shibboleth_for(user)
  Rails.configuration.shibboleth = true
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:shibboleth] = OmniAuth::AuthHash.new(
    provider: "shibboleth",
    uid: user.uid,
    info: { "email" => user.email }
  )
  Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
  Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:shibboleth]
end
