class Users::SessionsController < Devise::SessionsController
  # /users/sign_in
  def new
    redirect_to user_omniauth_authorize_path(Devise.omniauth_configs.keys.first)
  end

  # DELETE /users/sign_out
  def destroy
    redirect_path = after_sign_out_path_for(resource_name)
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))

    if signed_out && is_navigational_format?
      flash[:alert] = 'You have been logged out of Starlight!'
    else
      logger.warn "Sign out failed for #{resource_name}"
    end

    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request
    # TODO: ensure this issue still persists with working environments (IT IS OLD)
    respond_to do |format|
      format.all { head :no_content }
      format.any(*navigational_formats) { redirect_to redirect_path }
    end
  end
end
