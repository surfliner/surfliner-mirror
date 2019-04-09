# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

require_relative '../../config/environment'

RSpec.describe 'GET /health' do
  include ::Rack::Test::Methods

  let(:app) { Lark.application }

  describe '/complete' do
    it 'returns success' do
      get '/health/complete'

      expect(last_response).to have_attributes status: 200
    end
  end
end
