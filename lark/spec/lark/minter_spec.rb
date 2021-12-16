# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lark::Minter do
  describe ".for" do
    it "gives a UUID minter" do
      expect(described_class.for(:uuid)).to be_a described_class
    end

    it "can find an Ezid minter" do
      expect(described_class.for(:ezid)).to be_a Lark::EzidMinter
    end

    it "errors on unexpected minter types" do
      expect { described_class.for(:NOT_A_MINTER_AT_ALL) }.to raise_error(/NOT_A_MINTER_AT_ALL/)
    end
  end

  describe "#mint" do
    subject(:minter) { described_class.new }

    let(:uuid) { "20b0d603-0a66-44e5-8596-be9ad32ea4cd" }

    before { allow(SecureRandom).to receive(:uuid).and_return(uuid) }

    it "returns an SecureRandom uuid" do
      expect(minter.mint).to be uuid
    end
  end
end
