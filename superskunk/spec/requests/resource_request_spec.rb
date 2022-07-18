require "rails_helper"
require "rack/test"

RSpec.describe "GET /resources/{id}" do
  include ::Rack::Test::Methods

  let(:app) { Rails.application }
  let(:id) { "abc" }

  describe "no user agent" do
    it "can’t get anything" do
      get "resources/#{id}", {}, {
        "HTTP_ACCEPT" => "*/*"
      }
      expect(last_response.ok?).to be false
    end
  end

  describe "OAI/DC" do
    let(:profile) { "tag:surfliner.gitlab.io,2022:api/oai_dc" }
    let(:user_agent) { "surfliner.tidewater" }

    it "gets OAI/DC" do
      get "/resources/#{id}", {}, {
        "HTTP_ACCEPT" => "application/ld+json;profile=\"#{profile}\"",
        "HTTP_USER_AGENT" => user_agent
      }
      expect(last_response.ok?).to be true
    end

    it "prioritizes over unknown profiles" do
      get "/resources/#{id}", {}, {
        "HTTP_ACCEPT" =>
          "application/ld+json;profile=\"example:unknown\";q=1,"\
          "application/ld+json;profile=\"#{profile}\";q=0.001",
        "HTTP_USER_AGENT" => user_agent
      }
      expect(last_response.ok?).to be true
    end

    it "responds with the correct Content-Type" do
      get "/resources/#{id}", {}, {
        "HTTP_ACCEPT" => "application/ld+json;profile=\"#{profile}\"",
        "HTTP_USER_AGENT" => user_agent
      }
      expect(last_response.headers["Content-Type"]).to match(/;\s*profile="#{Regexp.escape(profile)}"/)
    end
  end

  describe "unknown profile" do
    let(:profile) { "example:unknown_profile" }
    let(:user_agent) { "surfliner.tidewater" }

    it "can’t get anything" do
      get "/resources/#{id}", {}, {
        "HTTP_ACCEPT" => "application/ld+json;profile=\"#{profile}\"",
        "HTTP_USER_AGENT" => user_agent
      }
      expect(last_response.ok?).to be false
    end
  end

  describe "bad profile" do
    let(:profile) { "tag:surfliner.gitlab.io,2022:api/oai_dc" }
    let(:user_agent) { "surfliner.tidewater" }

    it "ignores profiles with q=0" do
      get "/resources/#{id}", {}, {
        "HTTP_ACCEPT" => "application/ld+json;profile=\"#{profile}\";q=0",
        "HTTP_USER_AGENT" => user_agent
      }
      expect(last_response.ok?).to be false
    end

    it "ignores profiles specified after q" do
      get "/resources/#{id}", {}, {
        "HTTP_ACCEPT" => "application/ld+json;profile=\"example:bad\";q=1;profile=\"#{profile}\"",
        "HTTP_USER_AGENT" => user_agent
      }
      expect(last_response.ok?).to be false
    end
  end

  describe "fallbacks" do
    let(:user_agent) { "surfliner.tidewater" }

    it "falls back for application/ld+json" do
      get "/resources/#{id}", {}, {
        "HTTP_ACCEPT" => "application/ld+json",
        "HTTP_USER_AGENT" => user_agent
      }
      expect(last_response.ok?).to be true
    end

    it "falls back for application/json" do
      get "/resources/#{id}", {}, {
        "HTTP_ACCEPT" => "application/json",
        "HTTP_USER_AGENT" => user_agent
      }
      expect(last_response.ok?).to be true
    end

    it "falls back for application/*" do
      get "/resources/#{id}", {}, {
        "HTTP_ACCEPT" => "application/*",
        "HTTP_USER_AGENT" => user_agent
      }
      expect(last_response.ok?).to be true
    end

    it "falls back for */*" do
      get "/resources/#{id}", {}, {
        "HTTP_ACCEPT" => "*/*",
        "HTTP_USER_AGENT" => user_agent
      }
      expect(last_response.ok?).to be true
    end
  end
end
