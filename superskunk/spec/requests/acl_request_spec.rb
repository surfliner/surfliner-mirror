require "rails_helper"
require "rack/test"

RSpec.describe "GET /acls?file={id}&mode={mode}&group={name}" do
  include ::Rack::Test::Methods

  let(:app) { Rails.application }
  let(:group) { Hyrax::Acl::Group.new("public") }
  let(:persister) { Valkyrie::MetadataAdapter.find(:comet_metadata_store).persister }
  let(:query_service) { Superskunk.comet_query_service }
  let(:resource) { persister.save(resource: FileMetadata.new(file_identifier: "file_1")) }

  before do
    class FileMetadata < Valkyrie::Resource # rubocop:disable Lint/ConstantDefinitionInBlock
      attribute :file_identifier
    end
  end

  after do
    persister.wipe!
    Object.send(:remove_const, :FileMetadata)
  end

  context "allows access against FileMetadata ACL" do
    before { resource } # ensure it is saved

    it "is falsey" do
      get "acls?file=file_1&mode=read&group=public", {}, {}

      expect(last_response).to have_attributes(status: 200, body: "0")
    end

    context "with access" do
      before do
        acl = Hyrax::Acl::AccessControlList.new(resource: resource, persister: persister, query_service: query_service)
        acl.grant(:read).to(group)
        acl.save
      end

      it "is truthy" do
        get "acls?file=file_1&mode=read&group=public", {}, {}

        expect(last_response).to have_attributes(status: 200, body: "1")
      end
    end
  end
end

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
      get "acls?resource=oops&mode=read&group=public", {}, {
        "HTTP_ACCEPT" => "*/*"
      }
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
