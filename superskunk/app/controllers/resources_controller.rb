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
    @profile = accept_reader.best_jsonld_profile(ResourceSerializer.supported_profiles.keys)

    if @model.instance_of?(Hyrax::FileSet)
      puts "Resource with ID #{@model.id} is a FileSet, querying its parent"
      parent = Superskunk.comet_query_service.find_parents(resource: @model).first

      if parent.nil?
        not_found
      else
        response.headers["Link"] = "</resources/#{parent.id}>; rel='http://pcdm.org/models#memberOf'"
        render_error exception: nil,
          text: "Cannot query FileSet metadata, see parent object",
          status: 406
      end
    elsif @model.instance_of?(Superskunk::Resource)
      puts "Resource with ID #{@model.id} is a Superskunk::Resource"
      render_error exception: nil,
        text: "Cannot query Superskunk::Resource metadata",
        status: 406

    elsif @platform.has_access?(resource: @model)
      @profile ? profile_render : default_render
    else
      not_found
    end
  end

  ##
  # Render a JSON-LD profile.
  def profile_render
    render json: ResourceSerializer.serialize(
      resource: @model,
      profile: @profile,
      agent: @platform
    )
  end

  ##
  # A default render used when no supported profile is requested.
  def default_render
    if accept_reader.best_type([
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
