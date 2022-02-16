require "rails_helper"
require "rack/test"

RSpec.describe "GET /resources/{id}" do
  include ::Rack::Test::Methods

  let(:app) { Rails.application }
  let(:id) { "abc" }

  describe "OAI/DC" do
    let(:profile) { "tag:surfliner.github.io,2022:api/oai_dc" }

    it "gets OAI/DC" do
      get "/resources/#{id}", {}, {
        "HTTP_ACCEPT" => "application/ld+json;profile=\"#{profile}\""
      }
      expect(last_response.ok?).to be true
    end

    it "prioritizes over unknown profiles" do
      get "/resources/#{id}", {}, {
        "HTTP_ACCEPT" =>
          "application/ld+json;profile=\"example:unknown\";q=1,"\
          "application/ld+json;profile=\"#{profile}\";q=0.001"
      }
      expect(last_response.ok?).to be true
    end

    it "responds with the correct Content-Type" do
      get "/resources/#{id}", {}, {
        "HTTP_ACCEPT" => "application/ld+json;profile=\"#{profile}\""
      }
      expect(last_response.headers["Content-Type"]).to match(/;\s*profile="#{Regexp.escape(profile)}"/)
    end
  end

  describe "unknown profile" do
    let(:profile) { "example:unknown_profile" }

    it "can’t get anything" do
      get "/resources/#{id}", {}, {
        "HTTP_ACCEPT" => "application/ld+json;profile=\"#{profile}\""
      }
      expect(last_response.ok?).to be false
    end
  end

  describe "bad profile" do
    let(:profile) { "tag:surfliner.github.io,2022:api/oai_dc" }

    it "ignores profiles with q=0" do
      get "/resources/#{id}", {}, {
        "HTTP_ACCEPT" => "application/ld+json;profile=\"#{profile}\";q=0"
      }
      expect(last_response.ok?).to be false
    end

    it "ignores profiles specified after q" do
      get "/resources/#{id}", {}, {
        "HTTP_ACCEPT" => "application/ld+json;profile=\"example:bad\";q=1;profile=\"#{profile}\""
      }
      expect(last_response.ok?).to be false
    end
  end

  describe "fallbacks" do
    it "falls back for application/ld+json" do
      get "/resources/#{id}", {}, {
        "HTTP_ACCEPT" => "application/ld+json"
      }
      expect(last_response.ok?).to be true
    end

    it "falls back for application/json" do
      get "/resources/#{id}", {}, {
        "HTTP_ACCEPT" => "application/json"
      }
      expect(last_response.ok?).to be true
    end

    it "falls back for application/*" do
      get "/resources/#{id}", {}, {
        "HTTP_ACCEPT" => "application/*"
      }
      expect(last_response.ok?).to be true
    end

    it "falls back for */*" do
      get "/resources/#{id}", {}, {
        "HTTP_ACCEPT" => "*/*"
      }
      expect(last_response.ok?).to be true
    end
  end
end
