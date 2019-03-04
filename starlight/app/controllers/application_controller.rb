class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Spotlight::Controller

  layout 'blacklight'

  protect_from_forgery with: :exception

  # We are not using :database_authenticatable, so we need to define the helper method new_session_path(scope) so it can correct redirect on failure
  def new_session_path(_scope)
    new_user_session_path
  end
end
