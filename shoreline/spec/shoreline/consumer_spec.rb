require "spec_helper"
require "json"
require "opentelemetry/sdk"
require "shoreline/consumer"

require File.expand_path("../../config/environment", __dir__)

RSpec.describe Shoreline::Consumer, :webmock do
  subject(:consumer) { described_class.new(tracer: tracer, importer: spy_importer, logger: logger) }
  let(:logger) { Logger.new(IO::NULL) }
  let(:tracer) { OpenTelemetry.tracer_provider.tracer("Test Consumer Tracer") }

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

  let(:spy_importer) do
    Class.new do
      attr_reader :deleted, :ingested

      def delete(**opts)
        @deleted ||= []
        @deleted << opts
      end

      def ingest(**opts)
        @ingested ||= []
        @ingested << opts
      end
    end.new
  end

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

  describe "#process_resource" do
    let(:resource_uri) { "http://superskunk/resources/555555" }
    let(:resource_id) { "555555" }

    context "when published" do
      let(:status) { :published }

      it "ingests the object metadata" do
        expect { consumer.process_resource(resource_uri, resource_id, status) }
          .to change { spy_importer.ingested&.first }
          .to include(metadata: include("id" => "555555"))
      end
    end

    context "when unpublished" do
      let(:status) { :unpublished }
      it "deletes the object metadata using resource_uri id as identifier" do
        expect { consumer.process_resource(resource_uri, resource_id, status) }
          .to change { spy_importer.deleted&.first }
          .to include(id: "555555")
      end
    end
  end

  describe "#process_identifier" do
    context "when an ark is provided in payload" do
      let(:payload) do
        {"resourceUrl" => "http://superskunk/resources/555555",
         "ark" => "ark:/99999/fk4tq65d6k"}
      end
      it "uses a formatted ark as the identifier" do
        expect(consumer.process_identifier(payload)).to eq("99999-fk4tq65d6k")
      end
    end
    context "when an ark is not provided in payload" do
      let(:payload) do
        {"resourceUrl" => "http://superskunk/resources/555555"}
      end
      it "uses the resource_uri id as the identifier" do
        expect(consumer.process_identifier(payload)).to eq("555555")
      end
    end
  end

  describe Shoreline::Consumer::Record do
    subject(:record) { described_class.new(data: JSON.parse(json)) }

    it { is_expected.to have_attributes(file_urls: be_empty) }

    describe ".load" do
      it "returns a record with an id" do
        expect(described_class.load(resource_uri, logger: logger))
          .to have_attributes(id: "555555")
      end
    end
  end

  describe Shoreline::Consumer::Connection do
    subject(:connection) { described_class.new(logger: logger) }

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
