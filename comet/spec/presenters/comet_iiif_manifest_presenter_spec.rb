# frozen_string_literal: true

# rubocop:disable BracesAroundHashParameters maybe a rubocop bug re hash params?
RSpec.describe CometIiifManifestPresenter do
  subject(:presenter) { described_class.new(work) }
  let(:work) { build(:monograph) }

  describe "manifest generation" do
    let(:builder_service) { Hyrax::ManifestBuilderService.new }

    it "generates a IIIF presentation 2.0 manifest" do
      expect(builder_service.manifest_for(presenter: presenter))
        .to include("@context" => "http://iiif.io/api/presentation/2/context.json")
    end
  end

  describe "#description" do
    it "returns a string description of the object" do
      expect(presenter.description).to be_a String
    end
  end

  describe "#manifest_metadata" do
    it "includes empty metadata" do
      expect(presenter.manifest_metadata)
        .to contain_exactly({"label" => "Title", "value" => []},
          {"label" => "Creator", "value" => []},
          {"label" => "Rights statement", "value" => []})
    end

    context "with some metadata" do
      let(:work) do
        build(:monograph,
          title: ["Comet in Moominland", "Mumintrollet på kometjakt"],
          creator: "Tove Jansson",
          rights_statement: "free!",
          description: "A book about moomins")
      end

      it "includes configured metadata" do
        expect(presenter.manifest_metadata)
          .to contain_exactly({"label" => "Title", "value" => ["Comet in Moominland", "Mumintrollet på kometjakt"]},
            {"label" => "Creator", "value" => ["Tove Jansson"]},
            {"label" => "Rights statement", "value" => ["free!"]})
      end
    end
  end

  describe "#manifest_url" do
    let(:work) { build(:monograph) }

    it "gives an empty string for an unpersisted object" do
      expect(presenter.manifest_url).to be_empty
    end

    context "with a persisted work" do
      let(:work) { valkyrie_create(:monograph) }

      it "builds a url from the manifest path and work id " do
        expect(presenter.manifest_url).to include "concern/monographs/#{work.id}/manifest"
      end
    end
  end
end
# rubocop:enable Style/BracesAroundHashParameters
