# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lark::Transactions::CreateAuthority do
  subject(:transaction) { described_class.new(event_stream: event_stream) }

  let(:event_stream)    { [] }

  describe '#call' do
    it 'adds :create to the event stream' do
      expect { transaction.call(attributes: {}) }
        .to change { event_stream }
        .to include have_attributes(type: :create)
    end

    it 'returns an authority with an id' do
      expect(transaction.call(attributes: {}).value!)
        .to have_attributes(id: an_instance_of(Valkyrie::ID))
    end
  end
end
