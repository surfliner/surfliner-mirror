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
      @model = GenericObject.new
      # Waiting for Access Controls before we allow this…
      #
      # @model = Superskunk.comet_query_service.find_by(id: params.id)
    rescue Valkyrie::Persistence::ObjectNotFoundError
      return render_error text: "Not Found", status: 404
    end

    # Get the profile.
    begin
      @accept_reader = AcceptReader.new(request.headers["Accept"])
      @profile = @accept_reader.best_jsonld_profile(supported_renderers.keys)
    rescue AcceptReader::BadAcceptError
      return render_error text: "Bad Accept Header", status: 400
    end

    # Render the appropriate mapping.
    @profile_mappings = mappings_for(@profile)
    public_send supported_renderers[@profile] || :default_render
  end

  ##
  # Render an error as JSON.
  def render_error(text: "Server Error", status: 500)
    @profile = nil
    render json: {"error" => text, "status" => status}, status: status
  end

  ##
  # Render the resource as OAI∕DC.
  def render_oai_dc
    mapped = [
      "contributor",
      "coverage",
      "creator",
      "date",
      "description",
      "format",
      "identifier",
      "language",
      "publisher",
      "relation",
      "rights",
      "source",
      "subject",
      # "title" is skipped as it needs special handling below
      "type"
    ].each_with_object({}) do |term, json|
      # OAI doesn’t support datatyping so everything should be cast to a string.
      mapping = @profile_mappings["http://purl.org/dc/elements/1.1/#{term}"].to_a.map(&:to_s)
      json[term] = mapping if mapping.size > 0
    end
    render json: {
      "@context" => {
        "@vocab" => "http://purl.org/dc/elements/1.1/",
        "ore" => "http://www.openarchives.org/ore/terms/"
      },
      "@id" => "#{ENV["SUPERSKUNK_API_BASE"]}/resources/#{@model.id}",
      "title" => @profile_mappings["http://purl.org/dc/elements/1.1/title"].to_a.map(&:to_s) + @model.title.to_a, # the Hyrax title is not mapped rn
      **mapped
    }
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
      render_oai_dc
    end
  end

  private

  ##
  # Provides a hash of strings to sets of mappings for the provided schema IRI.
  def mappings_for(schema_iri)
    @model.mapped_to(schema_iri)
  end

  ##
  # Renderers supported for the given model.
  def supported_renderers
    case @model.internal_resource.to_sym
    when :GenericObject
      {"tag:surfliner.gitlab.io,2022:api/oai_dc" => :render_oai_dc}
    else
      {}
    end
  end

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
