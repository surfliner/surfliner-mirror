##
# A simple controller that resolves requests for authority records.
class RecordController
  ##
  # @!attribute [r] params
  #   @return [Hash<String, String>]
  # @!attribute [r] request
  #   @return [Rack::Request]
  attr_reader :params, :request

  ##
  # @param params  [Hash<String, String>]
  # @param request [Rack::Request]
  def initialize(params: nil, request: nil, config: Lark.config)
    @config  = config
    @params  = params
    @request = request
  end

  ##
  # Creates a new authority record from the request
  def create
    event_stream << Event.new(type: :create, data: parsed_body(format: ctype))

    [201, {}, ['']]
  end

  ##
  # https://dry-rb.org/gems/dry-view/
  def show
    record = query_service.find_by(id: params['id'])
    json   = { id: record.id.to_s, pref_label: record.pref_label.first }.to_json

    [200, {}, [json]]
  rescue Valkyrie::Persistence::ObjectNotFoundError => err
    [404, {}, [err.message]]
  end

  private

  def adapter
    Valkyrie::MetadataAdapter.find(@config.index_adapter)
  end

  def event_stream
    @config.event_stream
  end

  def ctype
    request.env['CONTENT_TYPE']
  end

  def parsed_body(format:)
    Lark::RecordParser
      .for(content_type: format)
      .parse(request.body)
  end

  def query_service
    adapter.query_service
  end
end
