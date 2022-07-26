class ApplicationController < ActionController::API
  rescue_from Valkyrie::Persistence::ObjectNotFoundError, with: :not_found

  def not_found
    render plain: "Not Found", status: 404
  end
end
