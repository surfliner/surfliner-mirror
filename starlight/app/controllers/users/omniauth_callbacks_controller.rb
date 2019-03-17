# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # This necessary to prevent CSRF errors on the developer strategy callback
  # see: https://github.com/omniauth/omniauth/wiki/FAQ#rails-session-is-clobbered-after-callback-on-developer-strategy
  skip_before_action :verify_authenticity_token, only: :developer

  # Matches omniauth 'developer' strategy set in config/devise.yml
  # This is used for local testing and development
  def developer
    find_or_create_user("developer")
  end

  # Matches omniauth 'shibboleth' strategy set in config/devise.yml
  # This is used for staging and production envirnoments
  def shibboleth
    find_or_create_user("shibboleth")
  end

  # Responsible for handling the authentication callback for omniauth strategies
  # Call out to User model persistence methods for each omniauth strategy. Examples being `User.from_omniauth` and
  # `User.from_developer`
  # @param auth_type [String] Current options 'developer' and 'shibboleth'
  def find_or_create_user(auth_type)
    logger.debug "#{auth_type} :: #{current_user.inspect}"
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      flash[:success] = I18n.t "devise.omniauth_callbacks.success", kind: auth_type.capitalize
      sign_in @user, event: :authentication
    else
      session["devise.#{auth_type.downcase}_data"] = request.env["omniauth.auth"]
    end
    redirect_to request.env["omniauth.origin"] || root_url
  end

  def failure
    redirect_to root_path
  end
end
