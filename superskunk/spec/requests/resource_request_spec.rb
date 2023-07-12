require "rails_helper"
require "rack/test"

RSpec.describe "GET /resources/{id}" do
  include ::Rack::Test::Methods

  let(:app) { Rails.application }
  let(:persister) { Valkyrie::MetadataAdapter.find(:comet_metadata_store).persister }
  let(:title) { "Webster’s New World Dictionary of the American Language" }
  let(:resource) { persister.save(resource: GenericObject.new(title: [title])) }
  let(:id) { resource.id }
  let(:user_agent) { "surfliner.superskunk.test_suite" }
  let(:group) { Hyrax::Acl::Group.new(user_agent) }

  let(:acl) do
    persister.save(
      resource: Hyrax::Acl::AccessControl.new(access_to: resource.id, permissions: [permission])
    )
  end

  let(:permission) do
    Hyrax::Acl::Permission.new(access_to: resource.id, mode: :discover, agent: group.agent_key)
  end

  before { acl }

  describe "no user agent" do
    it "can’t get anything" do
      get "resources/#{id}", {}, {
        "HTTP_ACCEPT" => "*/*"
      }
      expect(last_response.ok?).to be false
    end
  end

  describe "unrecognized user agent" do
    it "can’t get anything" do
      get "resources/#{id}", {}, {
        "HTTP_ACCEPT" => "*/*",
        "HTTP_USER_AGENT" => "surfliner.superskunk.test_suite.bad"
      }
      expect(last_response.ok?).to be false
    end
  end

  describe "OAI/DC" do
    let(:profile) { "tag:surfliner.gitlab.io,2022:api/oai_dc" }

    it "gets OAI/DC" do
      get "/resources/#{id}", {}, {
        "HTTP_ACCEPT" => "application/ld+json;profile=\"#{profile}\"",
        "HTTP_USER_AGENT" => user_agent
      }
      result_json = JSON.parse(last_response.body.to_str)

      expect(last_response.ok?).to be true
      expect(result_json["@context"]).to include(
        "@vocab" => "http://purl.org/dc/elements/1.1/",
        "ore" => "http://www.openarchives.org/ore/terms/"
      )
      expect(result_json["title"]).to contain_exactly title
    end

    it "prioritizes over unknown profiles" do
      get "/resources/#{id}", {}, {
        "HTTP_ACCEPT" =>
          "application/ld+json;profile=\"example:unknown\";q=1," \
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

  describe "Aardvark" do
    let(:profile) { "tag:surfliner.gitlab.io,2022:api/aardvark" }

    it "gets Aardvark" do
      get "/resources/#{id}", {}, {
        "HTTP_ACCEPT" => "application/ld+json;profile=\"#{profile}\"",
        "HTTP_USER_AGENT" => user_agent
      }
      result_json = JSON.parse(last_response.body.to_str)

      expect(last_response.ok?).to be true
      expect(result_json["@context"]).to include(
        "dct_title_s" => "https://opengeometadata.org/ogm-aardvark/#title"
      )
      expect(result_json["dct_title_s"]).to eq title
    end

    it "has all required properties" do
      get "/resources/#{id}", {}, {
        "HTTP_ACCEPT" => "application/ld+json;profile=\"#{profile}\"",
        "HTTP_USER_AGENT" => user_agent
      }
      result_json = JSON.parse(last_response.body.to_str)

      expect(last_response.ok?).to be true
      expect(result_json.keys).to include(
        "dct_accessRights_s",
        "dct_title_s",
        "gbl_mdModified_dt",
        "gbl_mdVersion_s",
        "gbl_resourceClass_sm",
        "id"
      )
      expect(result_json["gbl_mdVersion_s"]).to eq "Aardvark"
      expect(result_json["id"]).to eq id
    end
  end

  describe "unknown profile" do
    let(:profile) { "example:unknown_profile" }

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
