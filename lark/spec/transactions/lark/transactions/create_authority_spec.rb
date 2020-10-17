# frozen_string_literal: true

require 'spec_helper'
require 'support/matchers/result'
require_relative '../../../../config/environment'

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

    context 'when the event stream raises a KeyError' do
      let(:event_stream) { fail_stream.new }

      let(:fail_stream) do
        Class.new do
          def <<(event)
            raise(KeyError, 'bad attribute!') if
              event.type == :change_properties
          end
        end
      end

      it 'gives a failure result' do
        expect(transaction.call(attributes: { oh_no: 'bad attribute'}))
          .to be_a_transaction_failure
          .with_reason(:unknown_attribute)
      end
    end

    context 'when the minter fails' do
      subject(:transaction) do
        described_class
          .new(event_stream: :FAKE_EVENT_STREAM, minter: FailureMinter.new)
      end

      it 'gives a failure result' do
        expect(transaction.call(attributes: {}))
          .to be_a_transaction_failure
          .with_reason(:minter_failed)
          .and_message('i always fail :(')
      end
    end
  end
end
