require "rails_helper"

RSpec.describe OaiItemProvider do
  let(:provider) { described_class.new }

  it "has a repository_url that matches the application OAI route" do
    provider_repository_url_route = provider.url.split("/").last
    expect(Rails.application.routes.routes.any? { |r| r.name.eql? provider_repository_url_route }).to be true
  end

  context "with OaiItem records" do
    describe "#get_record" do
      let(:oai_dc_metadata_xpath) { "OAI-PMH/GetRecord/record/metadata/oai_dc:dc".freeze }
      let(:oai_header_xpath) { "OAI-PMH/GetRecord/record/header".freeze }
      let!(:item) { OaiItem.create(title: "title", identifier: "ark://1234", creator: "surfliner") }
      let(:record) do
        REXML::Document.new(
          provider.get_record(
            identifier: "oai:test:#{item.id}",
            metadata_prefix: "oai_dc"
          )
        )
      end
      it "serializes OaiItem dublin core properties into the xml record" do
        expect(record.elements["#{oai_dc_metadata_xpath}/dc:title"].text).to eq item.title
        expect(record.elements["#{oai_dc_metadata_xpath}/dc:identifier"].text).to eq item.identifier
        expect(record.elements["#{oai_dc_metadata_xpath}/dc:creator"].text).to eq item.creator
      end
      it "populates header properties into the xml record" do
        expect(record.elements["#{oai_header_xpath}/identifier"].text).to eq "oai:test:#{item.id}"
      end
    end
  end
end
