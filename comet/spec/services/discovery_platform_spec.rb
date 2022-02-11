# frozen_string_literal: true

require "rails_helper"

RSpec.describe DiscoveryPlatform do
  subject(:platform) { described_class.new(platform_name) }
  let(:platform_name) { :tidewater }

  describe ".active_platforms" do
    let(:resource) do
      Hyrax.persister.save(resource: GenericObject.new(title: ["Comet in Moominland"]))
    end

    it "is empty when not published" do
      expect(described_class.active_platforms_for(resource: resource)).to be_none
    end

    context "when published in the discovery system" do
      let(:platforms) do
        [platform,
          described_class.new(:other_platform),
          described_class.new(:third_platform)]
      end

      before do
        acl = Hyrax::AccessControlList.new(resource: resource)
        platforms.each { |p| acl.grant(:discover).to(p.agent) }
        acl.save
      end

      it "lists active platforms when published" do
        expect(described_class.active_platforms_for(resource: resource))
          .to contain_exactly(*platforms)
      end
    end

    context "when resource is unsaved" do
      let(:resource) { GenericObject.new }

      it "is empty" do
        expect(described_class.active_platforms_for(resource: resource)).to be_none
      end
    end
  end

  describe "#agent" do
    it "is a group" do
      expect(platform.agent).to be_a Hyrax::Group
    end

    it "has a group name" do
      expect(platform.agent).to have_attributes name: "surfliner:tidewater"
    end
  end

  describe "#message_route" do
    it "has a metadata routing key" do
      expect(platform.message_route)
        .to have_attributes metadata_routing_key: "surfliner.metadata.tidewater"
    end

    it "has a metadata topic" do
      expect(platform.message_route)
        .to have_attributes metadata_topic: "surfliner.metadata"
    end
  end
end
