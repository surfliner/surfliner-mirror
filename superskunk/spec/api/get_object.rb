require "rails_helper"
require "rack/test"

RSpec.describe "GET /object/{id}" do
  include ::Rack::Test::Methods

  let(:app) { Rails.application }

  it "finds an object" do
    expect { get "/objects/abc" }.not_to raise_error
  end
end
