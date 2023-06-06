# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lark::Indexer do
  subject(:indexer) { described_class.new }
  let(:persister) { indexer.adapter.persister }

  describe "#find" do
    let(:concept) { FactoryBot.create(:concept) }

    before { persister.wipe! }

    it "finds an existing concept" do
      expect(indexer.find(concept.id)).to have_attributes(id: concept.id)
    end

    it "when there is no match raises ObjectNotFoundError" do
      expect { indexer.find("FAKE_ID") }
        .to raise_error Valkyrie::Persistence::ObjectNotFoundError
    end
  end

  describe "#index" do
    context "with id" do
      let(:concept) { FactoryBot.build(:concept) }

      before { persister.wipe! }

      it "returns a concept" do
        expect(indexer.index(data: concept)).to be_a Concept
      end

      context "and a label" do
        let(:concept) { FactoryBot.build(:concept, pref_label: ["moomin"]) }
        let(:rsolr) { RSolr.connect(url: ENV["SOLR_URL"]) }
        let(:get_doc) {
          -> { rsolr.get("select", params: {q: "id:#{concept.id}"})["response"]["docs"].first }
        }

        it "writes string equivalents for label properties to the index" do
          expect { indexer.index(data: concept) }.to change {
            get_doc.call&.fetch("pref_label_ssim", [])
          }.to contain_exactly("moomin")
        end
      end
    end

    context "with no id" do
      let(:concept) { Concept.new(pref_label: "moomin") }

      it "raise ArgumentError" do
        expect { indexer.index(data: concept) }
          .to raise_error(ArgumentError, "ID missing: #{concept.inspect}")
      end
    end
  end
end
