require "rails_helper"

RSpec.describe DiscoveryPlatform do
  subject { described_class.new(agent.name) }
  let(:agent) { Hyrax::Acl::Group.new("tidewater") }

  it "has a :has_access? method" do
    expect(subject.respond_to?(:has_access?)).to be true
  end

  context "has :discover access to resource" do
    let(:adapter) { Valkyrie::MetadataAdapter.find(:comet_metadata_store) }
    let(:persister) { adapter.persister }
    let(:resource_class) { Class.new(Valkyrie::Resource) }
    let(:resource) { persister.save(resource: resource_class.new(title: "Test object")) }

    let(:acl) do
      persister.save(
        resource: Hyrax::Acl::AccessControl.new(access_to: resource.id, permissions: [permission])
      )
    end

    let(:permission) do
      Hyrax::Acl::Permission.new(access_to: resource.id, mode: :discover, agent: agent.agent_key)
    end

    before { acl }

    it "gives access" do
      expect(subject.has_access?(resource: resource)).to be true
    end
  end
end
