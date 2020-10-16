# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/lark/minter'

RSpec.describe Lark::Minter do
  describe '.for' do
    it 'gives a UUID minter' do
      expect(described_class.for(:uuid)).to be_a described_class
    end

    it 'can find an Ezid minter' do
      expect(described_class.for(:ezid)).to be_a Lark::EzidMinter
    end

    it 'errors on unexpected minter types' do
      expect { described_class.for(:NOT_A_MINTER_AT_ALL) }.to raise_error /NOT_A_MINTER_AT_ALL/
    end
  end

  describe '#mint' do
    subject(:minter) { described_class.new }
    let(:uuid) { '20b0d603-0a66-44e5-8596-be9ad32ea4cd' }
    before { allow(SecureRandom).to receive(:uuid).and_return(uuid) }

    it 'returns an SecureRandom uuid' do
      expect(minter.mint).to be uuid
    end
  end
end

RSpec.describe Lark::EzidMinter do
  context 'with ezid minting enabled' do
    subject(:minter) { described_class.new }
    let(:ark) { 'ark:/99999/fk43f4wd4v' }
    let(:client) { instance_double(Ezid::Client) }
    let(:response) { instance_double(Ezid::MintIdentifierResponse, id: ark) }

    before do
      allow(Ezid::Client).to receive(:new).and_return(client)
      allow(client).to receive(:mint_identifier).and_return(response)
    end

    it 'returns an ark from ezid' do
      expect(minter.mint).to be ark
    end
  end
end
