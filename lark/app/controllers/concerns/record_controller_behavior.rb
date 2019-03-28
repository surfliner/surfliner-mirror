# frozen_string_literal: true

##
# A base module for resolving requests for authority records.
module RecordControllerBehavior
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

  def serialize(record:, format:)
    Lark::RecordSerializer
      .for(content_type: format)
      .serialize(record: record)
  end

  def query_service
    adapter.query_service
  end
end
