require 'spec_helper'
require 'valkyrie/specs/shared_specs'

require_relative '../../config/environment'

RSpec.describe Event do
  subject(:event)      { described_class.new }
  let(:resource_klass) { described_class }

  it_behaves_like 'a Valkyrie::Resource'

  describe '#type' do
    it 'accepts :Create' do
      expect { event.type = :Create }
        .to change { event.type }
        .to :Create
    end
  end

  describe '#data' do
    let(:data) { { id: 'moomin_id', type: :Concept } }
    it 'defaults to an empty hash' do
      expect(event.data).to eq({})
    end

    it 'accepts a new hash value' do
      expect { event.data = data }
        .to change { event.data }
        .from(be_empty)
        .to data
    end
  end
end
