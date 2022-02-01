require "rails_helper"
require "rack/test"

RSpec.describe "GET /object/{id}" do
  include ::Rack::Test::Methods

  let(:app) { Rails.application }

  it "finds an object" do
    expect { get "/objects/abc" }.not_to raise_error
  end

  it "gives some json" do
    get "/objects/abc"

    data = {"title" => "abc"}

    expect(JSON.parse(last_response.body)).to include(**data)
  end
end
