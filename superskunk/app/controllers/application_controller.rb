class ApplicationController < ActionController::API
  after_action :set_content_type

  rescue_from DiscoveryPlatform::AuthError, with: :forbidden
  rescue_from Valkyrie::Persistence::ObjectNotFoundError, with: :not_found

  ##
  # 403 FORBIDDEN
  #
  # Use this for authentication errors, but use +not_found+ for authorization
  # failures to avoid leaking information.
  def forbidden
    render_error text: "Forbidden", status: 403
  end

  ##
  # 404 NOT FOUND
  #
  # A resource may be not found because it doesn’t exist, or because the
  # requester is not authorized to view the resource.
  def not_found
    render_error text: "Not Found", status: 404
  end

  ##
  # Renders an error in a reasonable format.
  def render_error(_exception = nil, text: "Server Error", status: 500)
    render plain: text, status: status
    # render json: {"error" => text, "status" => status}, status: status
  end

  ##
  # The Content-Type of a non‐ok response.
  #
  # This will match the output of +render_error+, so there’s no reason to
  # override it unless you are using custom error handling.
  def err_content_type
    "text/plain"
  end

  ##
  # The Content-Type of an ok response.
  #
  # Override this in subclasses if a different Content-Type is desired!!
  def ok_content_type
    "text/plain"
  end

  private

  ##
  # Set the Content-Type of the resource based on whether or not it is
  # successful.
  def set_content_type
    response.headers["Content-Type"] = if response.ok?
      ok_content_type
    else
      err_content_type
    end
  end
end
