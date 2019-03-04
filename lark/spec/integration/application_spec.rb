# frozen_string_literal: true

require 'spec_helper'
require 'capybara_discoball'

require_relative '../../config/environment'

RSpec.describe Lark::Application do
  # We really want to start this server only once for the whole suite, so we use
  # an instance variable, against RuboCop's advisement.
  #
  # rubocop:disable RSpec/InstanceVariable
  let(:app_uri) { @app_uri }

  before(:context) do
    @app_uri = URI(Capybara::Discoball.spin(described_class))
  end
  # rubocop:enable RSpec/InstanceVariable

  RSpec::Matchers.define :be_json_for do |data_hash|
    match do |http_body|
      data_hash = data_hash.stringify_keys

      expect(JSON.parse(http_body)).to include data_hash
    end
  end

  it 'round-trips new Authorities' do
    data    = { some: :data }.to_json
    headers = { 'Content-Type' => 'application/json' }

    body          = Net::HTTP.post(app_uri, data, headers).body
    new_record_id = JSON.parse(body)['id']

    expect(Net::HTTP.get(app_uri + new_record_id))
      .to be_json_for(id: new_record_id)
  end
end
