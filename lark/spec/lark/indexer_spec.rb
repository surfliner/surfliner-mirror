# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/lark/indexer'
require_relative '../../config/environment'

RSpec.describe Lark::Indexer do
  subject(:indexer) { described_class.new }

  describe '#find' do
    let(:concept) { FactoryBot.create(:concept) }

    it 'finds an existing concept' do
      expect(indexer.find(concept.id)).to have_attributes(id: concept.id)
    end

    it 'when there is no match raises ObjectNotFoundError' do
      expect { indexer.find('FAKE_ID') }
        .to raise_error Valkyrie::Persistence::ObjectNotFoundError
    end
  end

  describe '#index' do
    let(:concept) { FactoryBot.build(:concept) }

    it 'returns a concept' do
      expect(indexer.index(data: concept)).to be_a Concept
    end
  end
end
