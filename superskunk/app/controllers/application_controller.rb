class ApplicationController < ActionController::API
  after_action :set_content_type

  rescue_from AcceptReader::BadAcceptError, with: :bad_request
  rescue_from DiscoveryPlatform::AuthError, with: :forbidden
  rescue_from Valkyrie::Persistence::ObjectNotFoundError, with: :not_found

  ##
  # 400 BAD REQUEST
  #
  # Use this for badly‐formed requests (e.g. headers which don’t match the HTTP
  # syntax).
  def bad_request(exception: nil)
    if exception.is_a?(AcceptReader::BadAcceptError)
      render_error text: "Bad Accept Header", status: 400
    else
      render_error text: "Bad Request", status: 400
    end
  end

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
    if preferred_type == :json
      render json: {"error" => text, "status" => status}, status: status
    else
      render plain: text, status: status
    end
  end

  ##
  # Returns an AcceptReader for the current request.
  def accept_reader
    @accept_reader ||= AcceptReader.new(request.headers["Accept"])
  end

  ##
  # Returns the preferred type for responses.
  def preferred_type
    return @preferred_type unless @preferred_type.nil?
    best_recognized_type = accept_reader.best_type([
      "application/ld+json",
      "application/json",
      "application/*",
      "text/plain",
      "text/*"
    ])
    @preferred_type = if best_recognized_type.nil?
      :unknown
    elsif best_recognized_type.start_with?("text/")
      :plaintext
    else
      :json
    end
  end

  ##
  # The Content-Type of a non‐ok response.
  #
  # This will match the output of +render_error+, so there’s no reason to
  # override it unless you are using custom error handling.
  def err_content_type
    preferred_type == :json ? "application/json" : "text/plain"
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
