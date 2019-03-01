class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def developer
    find_or_create_user('developer')
  end

  def shibboleth
    find_or_create_user('shibboleth')
  end

  def find_or_create_user(auth_type)
    auth_strategy_method = "from_#{auth_type.downcase}".to_sym
    logger.debug "#{auth_type} :: #{current_user.inspect}"
    User.send(auth_strategy_method, request.env["omniauth.auth"])
    if @user.persisted?
      flash[:success] = I18n.t "devise.omniauth_callbacks.success", kind: auth_type.capitalize
      sign_in @user, event: :authentication
    else
      session["devise.#{auth_type.downcase}_data"] = request.env["omniauth.auth"]
    end
    redirect_to request.env['omniauth.origin'] || root_url
  end

  def failure
    redirect_to root_path
  end
end
