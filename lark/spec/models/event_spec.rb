# frozen_string_literal: true

require 'spec_helper'
require 'valkyrie/specs/shared_specs'

require_relative '../../config/environment'

RSpec.describe Event do
  subject(:event)      { described_class.new }

  let(:resource_klass) { described_class }

  it_behaves_like 'a Valkyrie::Resource'

  describe '#type' do
    it 'accepts :create' do
      expect { event.type = :create }
        .to change(event, :type)
        .to :create
    end
  end

  describe '#data' do
    let(:data) { { id: 'moomin_id', type: :Concept } }

    it 'defaults to an empty hash' do
      expect(event.data).to eq({})
    end

    it 'accepts a new hash value' do
      expect { event.data = data }
        .to change(event, :data)
        .from(be_empty)
        .to data
    end
  end
end
