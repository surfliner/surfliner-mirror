# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource GenericObject`
require "rails_helper"
require "hyrax/specs/shared_specs/indexers"

RSpec.describe GenericObjectIndexer do
  let(:indexer_class) { described_class }
  let(:resource) { GenericObject.new }

  it_behaves_like "a Hyrax::Resource indexer"

  context "with RDF data" do
    before do
      resource.creator = [RDF::Literal("Tove")]
      resource.date_created = Date.today
    end

    it "gives string values for RDF Literals" do
      solr_doc = described_class.new(resource: resource).to_solr

      expect(solr_doc[:creator_tesim]).to eql ["Tove"]
      expect(solr_doc[:date_created_tesim]).to eql [Date.today]
    end
  end
end
