# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/lark/minter'

RSpec.describe Lark::Minter do
  describe '.mint' do
    context 'with ezid minting enabled' do
      let(:ark) { 'ark:/99999/fk43f4wd4v' }
      let(:client) { instance_double(Ezid::Client) }
      let(:response) { instance_double(Ezid::MintIdentifierResponse, id: ark) }

      before do
        ENV['EZID_ENABLED'] = 'true'
        allow(Ezid::Client).to receive(:new).and_return(client)
        allow(client).to receive(:mint_identifier).and_return(response)
      end

      after do
        ENV['EZID_ENABLED'] = 'false'
      end

      it 'returns an ark from ezid' do
        expect(described_class.mint).to be ark
      end
    end

    context 'with ezid minting disabled' do
      let(:uuid) { '20b0d603-0a66-44e5-8596-be9ad32ea4cd' }
      before { allow(SecureRandom).to receive(:uuid).and_return(uuid) }

      it 'returns an SecureRandom uuid' do
        expect(described_class.mint).to be uuid
      end
    end
  end
end
