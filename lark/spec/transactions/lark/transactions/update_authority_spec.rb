# frozen_string_literal: true

require "spec_helper"
require "support/matchers/result"

RSpec.describe Lark::Transactions::UpdateAuthority do
  subject(:transaction) do
    described_class.new(event_stream: event_stream, adapter: adapter)
  end

  let(:adapter) do
    Valkyrie::MetadataAdapter.find(Lark.config.index_adapter)
  end

  let(:event_stream) { [] }
  let(:authority) do
    adapter.persister.save(resource: FactoryBot.create(:concept))
  end

  describe "#call" do
    let(:attributes) { {pref_label: label} }
    let(:id) { authority.id }
    let(:label) { ["Label edited"] }

    it "adds :update_attributes to the event stream" do
      expect { transaction.call(id: id, attributes: attributes) }
        .to change { event_stream }
        .to contain_exactly have_attributes(type: :change_properties)
    end

    it "returns an updated authority" do
      value = transaction.call(id: id, attributes: attributes).value!
      expect(value[:id]).to eq authority.id
      expect(value[:pref_label]).to contain_exactly Label.new("Label edited")
    end

    context "with invalid properties" do
      let(:attributes) { {pref_label: label, not_an_attribute: "oh no"} }

      it "fails with :invalid_attributes" do
        expect(transaction.call(id: id, attributes: attributes))
          .to be_a_transaction_failure
          .with_reason(:invalid_attributes)
      end
    end
  end
end
