require "spec_helper"
require "json"
require "shoreline/consumer"
require "webmock/rspec"

RSpec.describe Shoreline::Consumer do
  describe Shoreline::Consumer::Record do
    subject(:record) { described_class.new(data: JSON.parse(json)) }

    let(:json) do
      <<~JSON
        {
          "@context": {
            "@base": "http://superskunk:3000/resources/",
            "dct_accessRights_s": "http://purl.org/dc/terms/accessRights",
            "dcat_bbox": "https://www.w3.org/ns/dcat#bbox",
            "locn_geometry": "http://www.w3.org/ns/locn#geometry",
            "id": "@id",
            "gbl_indexYear_im": "https://opengeometadata.org/docs/ogm-aardvark/index-year",
            "dct_language_sm": "http://purl.org/dc/terms/language",
            "gbl_mdVersion_s": "https://opengeometadata.org/docs/ogm-aardvark/metadata-version",
            "gbl_mdModified_dt": "https://opengeometadata.org/docs/ogm-aardvark/modified",
            "schema_provider_s": "https://schema.org/provider",
            "gbl_resourceClass_sm": "https://opengeometadata.org/docs/ogm-aardvark/resource-class",
            "dct_title_s": "http://purl.org/dc/terms/title"
          },
          "dct_accessRights_s": "Public",
          "dcat_bbox": "ENVELOPE(-117.247442,-116.962327,33.060232,32.542267)",
          "locn_geometry": "ENVELOPE(-117.247442,-116.962327,33.060232,32.542267)",
          "id": "555555",
          "gbl_indexYear_im": [
            2020
          ],
          "dct_language_sm": [
            "eng"
          ],
          "gbl_mdVersion_s": "Aardvark",
          "gbl_mdModified_dt": "2023-06-28T18:13:48Z",
          "schema_provider_s": "Surfliner Team",
          "gbl_resourceClass_sm": [
            "Datasets"
          ],
          "dct_title_s": "Recycled Water Mains, San Diego, California, 2020"
        }
      JSON
    end

    it { is_expected.to have_attributes(file_urls: be_empty) }

    describe ".load" do
      let(:resource_uri) { "http://superskunk/resources/555555" }

      before do
        stub_request(:get, resource_uri)
          .with(
            headers: {
              "Accept" => 'application/ld+json;profile="tag:surfliner.gitlab.io,2022:api/shoreline/ingest"',
              "User-Agent" => "surfliner.shoreline"
            }
          )
          .to_return(status: 200, body: json, headers: {})
      end

      it "returns a record with an id" do
        expect(described_class.load(resource_uri))
          .to have_attributes(id: "555555")
      end
    end
  end

  describe Shoreline::Consumer::Connection do
    subject(:connection) { described_class.new }

    describe "#connect" do
      it "establishes a connection" do
        expect { connection.connect }
          .to change { connection.connection&.status }
          .to(:open)
      end

      it "opens a channel" do
        expect { connection.connect }
          .to change { connection.channel&.status }
          .to(:open)
      end
    end

    describe "#close" do
      it "closes a connection" do
        connection.connect

        expect { connection.close }
          .to change { connection.connection&.status }
          .from(:open)
          .to(:closed)
      end

      it "closes a channel" do
        connection.connect

        expect { connection.close }
          .to change { connection.channel&.status }
          .from(:open)
          .to(:closed)
      end

      it "when the channel isn't open still closes connection it's not open" do
        connection.connect
        connection.channel.close

        expect {
          begin
            connection.close
          rescue
            Bunny::ChannelAlreadyClosed
          end
        }
          .to change { connection.connection&.status }
          .to(:closed)
      end
    end
  end
end
