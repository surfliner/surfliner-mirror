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
def omniauth_setup_dev_auth_for(user)
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:developer] = OmniAuth::AuthHash.new(
    provider: "developer",
    uid: user.uid,
    info: { "email" => user.email }
  )
  Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
  Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:developer]
end
