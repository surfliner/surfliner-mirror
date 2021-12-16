# frozen_string_literal: true

require "spec_helper"

RSpec.describe SearchController do
  let(:adapter) do
    Valkyrie::MetadataAdapter.find(Lark.config.index_adapter)
  end
  let(:persister) { adapter.persister }

  describe "#search" do
    subject(:controller) { described_class.new(params: params) }

    before do
      FactoryBot.create(:concept,
        pref_label: ["PrefLabel Search"],
        alternate_label: ["AlternateLabel Search"])
    end

    after { persister.wipe! }

    context "when search with no results" do
      let(:params) { {"pref_label" => "Any Label"} }

      it "returns a 404 status with no results" do
        expect(controller.exact_search[0]).to eq 404
      end
    end

    context "when search with an unknown term" do
      let(:params) { {"any_term" => "Any term"} }

      it "return a 400 bad request status" do
        expect(controller.exact_search[0]).to eq 400
      end
    end

    context "when search by pref_label" do
      let(:params) { {"pref_label" => "PrefLabel Search"} }

      it "return a 200 status" do
        expect(controller.exact_search[0]).to eq 200
      end
    end

    context "when search by alternate_label" do
      let(:params) { {"alternate_label" => "AlternateLabel Search"} }

      it "return a 200 status" do
        expect(controller.exact_search[0]).to eq 200
      end
    end
  end
end
