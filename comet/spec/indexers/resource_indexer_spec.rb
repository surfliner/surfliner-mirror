# frozen_string_literal: true

require "rails_helper"
require "hyrax/specs/shared_specs/indexers"

RSpec.describe Indexers::ResourceIndexer do
  let(:current_date) { Date.today }
  let(:indexer_class) { Indexers::ResourceIndexer(GenericObject) }
  let(:resource) { GenericObject.new }
  let(:resource_indexer) { indexer_class.new(resource: resource) }

  it_behaves_like "a Hyrax::Resource indexer"

  context "with RDF data" do
    before do
      resource.creator = [RDF::Literal("Tove")]
      resource.date_created = [RDF::Literal(current_date, datatype: RDF::XSD.date)]
    end

    it "gives appropriate values for string literals" do
      solr_doc = resource_indexer.to_solr

      expect(solr_doc[:creator_tesim]).to eql ["Tove"]
    end

    it "gives appropriate values for date literals" do
      solr_doc = resource_indexer.to_solr

      expect(solr_doc[:date_created_tesim]).to eql [current_date]
    end
  end
end
