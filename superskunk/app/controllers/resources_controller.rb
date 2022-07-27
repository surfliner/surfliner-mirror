##
# Support API actions for Valkyrie resources.
class ResourcesController < ApplicationController
  ##
  # Show metadata for the requested resource.
  #
  # Many of the errors which may arise in this process are handled in
  # +ApplicationController+, so this code mostly assumes successful cases.
  def show
    @platform = DiscoveryPlatform.from_request(request)
    @model = Superskunk.comet_query_service.find_by(id: params["id"])

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
      not_found
    end
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

  ##
  # The Content-Type of a successful request.
  def ok_content_type
    if @profile
      "application/ld+json; profile=\"#{@profile}\""
    else
      "application/ld+json"
    end
  end
end
