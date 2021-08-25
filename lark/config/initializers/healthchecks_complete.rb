# frozen_string_literal: true

Rack::Healthcheck::Actions::Complete.class_eval do
  def get
    perform
    raise Lark::RequestError, result.to_json unless result[:status]

    ["200", {"Content-Type" => "application/json"}, [result.to_json]]
  rescue Lark::RequestError => e
    [e.status, {}, [e.message]]
  end
end
