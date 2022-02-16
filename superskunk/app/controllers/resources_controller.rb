##
# Support API actions for Valkyrie resources.
class ResourcesController < ApplicationController
  after_action :set_content_type

  def show
    begin
      @model = GenericObject.new
      # @model = Superskunk.pg_query_service.find_by(id: params.id)
    rescue Valkyrie::Persistence::ObjectNotFoundError
      return render_error text: "Not Found", status: 404
    end
    begin
      @accept_reader = AcceptReader.new(request.headers["Accept"])
      @profile = @accept_reader.best_jsonld_profile(supported_renderers.keys)
    rescue AcceptReader::BadAcceptError
      return render_error text: "Bad Accept Header", status: 400
    end
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
    render json: {
      "@context" => {
        "@vocab" => "http://purl.org/dc/elements/1.1/",
        "ore" => "http://www.openarchives.org/ore/terms/"
      },
      "@id" => "#{ENV["SUPERSKUNK_API_BASE"]}/resources/#{@model.id}",
      "title" => @model.title
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
      render_error text: "Unknown Accept Type", status: 406
    else
      @profile = "tag:surfliner.github.io,2022:api/oai_dc"
      render_oai_dc
    end
  end

  private

  ##
  # Renderers supported for the given model.
  def supported_renderers
    case @model.internal_resource.to_sym
    when :GenericObject
      {"tag:surfliner.github.io,2022:api/oai_dc" => :render_oai_dc}
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
