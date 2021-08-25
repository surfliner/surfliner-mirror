# frozen_string_literal: true

require "spec_helper"
require "lark/client/authority"

RSpec.describe Lark::Client::Authority do
  subject(:authority) { described_class.new(**attributes) }

  let(:attributes) do
    {pref_label: "Moomin"}
  end

  describe "#type" do
    it "defaults to :concept" do
      expect(authority.type).to eq :concept
    end
  end

  describe "pref_label" do
    it "has the assigned value" do
      expect(authority.pref_label).to eq attributes[:pref_label]
    end
  end
end
