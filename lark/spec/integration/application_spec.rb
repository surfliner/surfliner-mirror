# frozen_string_literal: true

require "spec_helper"
require "capybara_discoball"

RSpec.describe Lark::Application do
  let(:app_uri) { @app_uri }

  before(:context) do
    @app_uri = URI(Capybara::Discoball.spin(described_class))
  end

  RSpec::Matchers.define :be_json_for do |data_hash|
    match do |http_body|
      data_hash = data_hash.stringify_keys

      expect(JSON.parse(http_body)).to include data_hash
    end
  end

  it "round-trips new Authorities" do
    data = {id: "a_fake_id", pref_label: "Moomin"}.to_json
    headers = {"Content-Type" => "application/json"}

    body = Net::HTTP.post(app_uri, data, headers).body
    new_record_id = JSON.parse(body)["id"]

    expect(Net::HTTP.get(app_uri + new_record_id))
      .to be_json_for(id: new_record_id, pref_label: ["Moomin"])
  end

  it "mints ids for new authorities" do
    data = {pref_label: "Moomin"}.to_json
    headers = {"Content-Type" => "application/json"}

    body = Net::HTTP.post(app_uri, data, headers).body

    expect(JSON.parse(body)["id"]).not_to be_empty
  end
end
