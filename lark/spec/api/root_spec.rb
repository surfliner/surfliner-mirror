# frozen_string_literal: true

require "spec_helper"
require "rack/test"

RSpec.describe "GET /" do
  include ::Rack::Test::Methods

  let(:app) { Lark.application }

  before { get "/" }

  it "returns 200" do
    expect(last_response.status).to eq 200
  end

  it "defaults to a json response" do
    expect(last_response.headers)
      .to include "Content-Type" => "application/json"
  end

  it "provides an api service description" do
    expect(JSON.parse(last_response.body))
      .to include "version" => an_instance_of(String)
  end

  it "has header for CORS request" do
    expect(last_response.headers)
      .to include "Access-Control-Allow-Origin" => "*"
  end
end
