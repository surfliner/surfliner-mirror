# frozen_string_literal: true

Geoserver::Publish::Connection.class_eval do
  def put(path:, payload:, content_type:)
    response = faraday_connection.put do |req|
      req.url path
      req.headers['Content-Type'] = content_type
      req.body = payload
    end
    return true if response.status == 201 || response.status == 200

    raise Geoserver::Publish::Error, response.reason_phrase
  end
end
