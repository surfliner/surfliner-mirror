# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/lark/ezid_minter"

RSpec.describe Lark::EzidMinter do
  context "with ezid minting enabled" do
    subject(:minter) { described_class.new }

    let(:ark) { "ark:/99999/fk43f4wd4v" }
    let(:client) { instance_double(Ezid::Client) }
    let(:response) { instance_double(Ezid::MintIdentifierResponse, id: ark) }

    before do
      allow(Ezid::Client).to receive(:new).and_return(client)
      allow(client).to receive(:mint_identifier).and_return(response)
    end

    it "returns an ark from ezid" do
      expect(minter.mint).to be ark
    end

    context "when it cannot reach ezid" do
      before do
        allow(client).to receive(:mint_identifier).and_raise(Ezid::Error)
      end

      it "raises a MinterError" do
        expect { minter.mint }.to raise_error Lark::Minter::MinterError
      end
    end
  end
end
