require "rails_helper"
require "rack/test"

RSpec.describe "GET /acls?resource={id}&mode={mode}&group={name}" do
  include ::Rack::Test::Methods

  let(:app) { Rails.application }
  let(:group) { Hyrax::Acl::Group.new("public") }
  let(:persister) { Valkyrie::MetadataAdapter.find(:comet_metadata_store).persister }
  let(:query_service) { Superskunk.comet_query_service }
  let(:resource) { persister.save(resource: GenericObject.new(title: [title])) }
  let(:title) { "Webster’s New World Dictionary of the American Language" }

  context "without access" do
    it "is falsey" do
      get "acls?resource=#{resource.id}&mode=read&group=public", {}, {}

      expect(last_response).to have_attributes(status: 200, body: "0")
    end
  end

  context "when resource is missing" do
    it "is falsey" do
      get "acls?resource=oops&mode=read&group=public", {}, {}

      expect(last_response).to have_attributes(status: 200, body: "0")
    end
  end

  context "with a resource" do
    before { persister.save(resource: resource) }

    it "is falsey" do
      get "acls?resource=#{resource.id}&mode=read&group=public", {}, {}

      expect(last_response).to have_attributes(status: 200, body: "0")
    end

    context "with access" do
      before do
        acl = Hyrax::Acl::AccessControlList.new(resource: resource, persister: persister, query_service: query_service)
        acl.grant(:read).to(group)
        acl.save
      end

      it "is truthy" do
        get "acls?resource=#{resource.id}&mode=read&group=public", {}, {}

        expect(last_response).to have_attributes(status: 200, body: "1")
      end

      it "and group is not 'public', is falsey" do
        get "acls?resource=#{resource.id}&mode=read&group=moomin", {}, {}

        expect(last_response).to have_attributes(status: 200, body: "0")
      end
    end
  end
end
