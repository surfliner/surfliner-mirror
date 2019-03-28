# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

require_relative '../../config/environment'

RSpec.describe 'GET /' do
  include ::Rack::Test::Methods

  let(:app) { Lark.application }

  it 'returns 200' do
    get '/'

    expect(last_response.status).to eq 200
  end

  it 'defaults to a json response' do
    get '/'

    expect(last_response.headers)
      .to include 'Content-Type' => 'application/json'
  end

  it 'provides an api service description' do
    get '/'

    expect(JSON.parse(last_response.body))
      .to include 'version' => an_instance_of(String)
  end
end
