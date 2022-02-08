# frozen_string_literal: true

require "rails_helper"
require "rest-client"

RSpec.describe "consume Comet JSON-LD metadata" do
  let(:mocked_json_file) { Rails.root.join("spec", "fixtures", "mocked_metadata_response.json") }

  describe "#create" do
    let(:mocked_response) { RestClient.get("http://superskunk.example.com/1234") }

    before do
      stub_request(:get, "http://superskunk.example.com:80/1234")
        .to_return(body: File.new(mocked_json_file), status: 200)
    end

    it "returns 200 response and JSON-LD content" do
      expect(mocked_response.code).to eq 200
      expect(mocked_response.body).to include("http://arXiv.org/abs/cs/0112017")
    end
  end
end
