# frozen_string_literal: true

require "rails_helper"
require "hyrax/specs/shared_specs/indexers"

RSpec.describe Indexers::ResourceIndexer do
  let(:indexer_class) { Indexers::ResourceIndexer(GenericObject) }
  let(:resource) { GenericObject.new }
  let(:resource_indexer) { indexer_class.new(resource: resource) }

  it_behaves_like "a Hyrax::Resource indexer"

  context "with RDF data" do
    before do
      resource.creator = [RDF::Literal("Tove")]
      # resource.date_created = RDF::Literal(Date.today)
    end

    it "gives string values for RDF Literals" do
      solr_doc = resource_indexer.to_solr

      expect(solr_doc[:creator_tesim]).to eql ["Tove"]
    end

    xit "gives type appropriate string values for typed literals" do
      solr_doc = resource_indexer.to_solr

      expect(solr_doc[:date_created_tesim]).to eql [Date.today]
    end
  end
end
