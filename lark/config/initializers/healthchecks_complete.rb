# frozen_string_literal: true

Rack::Healthcheck::Actions::Complete.class_eval do
  def get
    perform
    raise Lark::RequestError, result.to_json unless result[:status]

    ['200', { 'Content-Type' => 'application/json' }, [result.to_json]]
  rescue Lark::RequestError => err
    [err.status, {}, [err.message]]
  end
end
