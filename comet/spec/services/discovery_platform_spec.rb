# frozen_string_literal: true

require "rails_helper"

RSpec.describe DiscoveryPlatform do
  subject(:platform) { described_class.new(platform_name) }
  let(:platform_name) { :tidewater }

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
