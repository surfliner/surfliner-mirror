require "rails_helper"

RSpec.describe DiscoveryPlatform do
  subject { described_class.new(agent_name) }
  let(:agent_name) { "tidewater" }

  it "has a :has_access? method" do
    expect(subject.respond_to?(:has_access?)).to be true
  end

  context "has :discover access to resource" do
    let(:adapter) { Valkyrie::MetadataAdapter.find(:comet_metadata_store) }
    let(:persister) { adapter.persister }
    let(:resource_class) { Superskunk::Test::Resource }
    let(:resource) { persister.save(resource: resource_class.new(title: "Test object")) }

    before do
      module Superskunk # rubocop:disable Lint/ConstantDefinitionInBlock
        module Test
          class Resource < Valkyrie::Resource
          end
        end
      end
    end

    after do
      Superskunk::Test.send(:remove_const, :Resource)
    end

    let(:acl) do
      persister.save(
        resource: Hyrax::Acl::AccessControl.new(access_to: resource.id, permissions: [permission])
      )
    end

    let(:permission) do
      Hyrax::Acl::Permission.new(access_to: resource.id, mode: :discover, agent: subject.agent_key)
    end

    before { acl }

    it "gives access" do
      expect(subject.has_access?(resource: resource)).to be true
    end
  end
end
