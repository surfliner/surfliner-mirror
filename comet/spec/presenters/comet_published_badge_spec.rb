require "rails_helper"

RSpec.describe CometPublishedBadge do
  let(:badge) { described_class.new("1234") }
  let(:platforms) { {} }

  describe "#render" do
    subject { badge.render }

    before do
      allow(DiscoveryPlatformService)
        .to receive(:call)
        .and_return(platforms)
    end

    context "when there are no published platforms" do
      let(:platforms) { [] }
      it { is_expected.to eq "<span class=\"badge badge-danger\">Unpublished</span>" }
    end

    context "when there is one published platforms" do
      let(:platforms) { [["Tidewater", "http://tidewater/1234"]] }
      it { is_expected.to eq "<span class=\"badge badge-success\">Published</span>" }
    end

    context "when there are multiple published platforms" do
      let(:platforms) { [["Tidewater", "http://tidewater/1234"], ["Shoreline", "http://shoreline/1234"]] }
      it { is_expected.to eq "<span class=\"badge badge-success\">Published</span>" }
    end
  end
end
