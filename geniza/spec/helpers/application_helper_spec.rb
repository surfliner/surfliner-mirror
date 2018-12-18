require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  let(:resource) { FactoryBot.create(:uploaded_resource) }
  let(:document) { SolrDocument.new }
  let(:manifest_url) { 'https://example.com/manifest' }
  let(:response) { { docs: [iiif_manifest_url_ssi: manifest_url] } }
  let(:manifest_service) { ManifestService.new(document: document) }

  describe "#iiif_manifest" do
    it "returns the iiif_manifest for a document" do
      allow(manifest_service).to receive(:url).and_return(manifest_url)
      expect(helper.iiif_manifest(manifest_service: manifest_service)).to eq(manifest_url)
    end
  end
end
