def sign_in
  visit new_user_session_path
end

def sign_out
  visit destroy_user_session_path
end

# Use integration test helpers provided by OmniAuth
# see: https://github.com/omniauth/omniauth/wiki/Integration-Testing
def omniauth_setup_shibboleth
  Rails.configuration.shibboleth = true
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:shibboleth] = OmniAuth::AuthHash.new(
    provider: 'shibboleth',
    uid: 'omniauth_test',
    info: { 'email' => 'test@ucsd.edu', 'name' => 'Dr. Seuss' }
  )
  Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
  Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:shibboleth]
end
