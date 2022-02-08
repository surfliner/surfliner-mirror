# frozen_string_literal: true

require "rails_helper"

RSpec.describe DiscoveryPlatform do
  subject(:platform) { described_class.new(platform_name) }
  let(:platform_name) { :tidewater }

  it { is_expected.to have_attributes routing_key: "surfliner.metadata.tidewater" }
  it { is_expected.to have_attributes topic: "surfliner.metadata" }

  describe "#agent" do
    it "is a group" do
      expect(platform.agent).to be_a Hyrax::Group
    end

    it "has a group name" do
      expect(platform.agent).to have_attributes name: "surfliner:tidewater"
    end
  end
end
