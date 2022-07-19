##
# Support API actions for Valkyrie resources.
class ResourcesController < ApplicationController
  after_action :set_content_type

  def show
    # Get the discovery platform.
    begin
      @platform = DiscoveryPlatform.from_request(request)
    rescue DiscoveryPlatform::AuthError
      return render_error text: "Forbidden", status: 403
    end

    # Get the model.
    begin
      @model = Superskunk.comet_query_service.find_by(id: params["id"])
    rescue Valkyrie::Persistence::ObjectNotFoundError
      return render_error text: "Not Found", status: 404
    end

    # Get the profile.
    begin
      @accept_reader = AcceptReader.new(request.headers["Accept"])
      @profile = @accept_reader.best_jsonld_profile(ResourceSerializer.supported_profiles.keys)
    rescue AcceptReader::BadAcceptError
      return render_error text: "Bad Accept Header", status: 400
    end

    # Render the appropriate mapping.
    if @platform.has_access?(resource: @model)
      @profile ? profile_render : default_render
    else
      # Render a 404 instead of a 403 if no access grant exists, so that the
      # presence/absense of resources isn’t leaked.
      render_error text: "Not Found", status: 404
    end
  end

  ##
  # Render an error as JSON.
  def render_error(text: "Server Error", status: 500)
    @profile = nil
    render json: {"error" => text, "status" => status}, status: status
  end

  ##
  # Render a JSON-LD profile.
  def profile_render
    render json: ResourceSerializer.serialize(resource: @model, profile: @profile)
  end

  ##
  # A default render used when no supported profile is requested.
  def default_render
    if @accept_reader.best_type([
      "application/ld+json",
      "application/json",
      "application/*",
      "*/*"
    ]).nil?
      render_error text: "Unknown Accept Type: #{request.headers["Accept"]}", status: 406
    else
      @profile = "tag:surfliner.gitlab.io,2022:api/oai_dc"
      profile_render
    end
  end

  private

  ##
  # Set the Content-Type of the response appropriately.
  def set_content_type
    response.headers["Content-Type"] = if !response.ok?
      "application/json"
    elsif @profile
      "application/ld+json; profile=\"#{@profile}\""
    else
      "application/ld+json"
    end
  end
end
