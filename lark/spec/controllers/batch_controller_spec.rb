# frozen_string_literal: true

require "spec_helper"
require "rack/test"

RSpec.describe BatchController do
  let(:adapter) do
    Valkyrie::MetadataAdapter.find(Lark.config.index_adapter)
  end
  let(:persister) { adapter.persister }

  let(:headers) { {"CONTENT_TYPE" => "application/json"} }

  let(:request) do
    instance_double(Rack::Request,
      body: body,
      env: headers)
  end

  before do
    persister.wipe!
  end

  describe "#batch_update" do
    subject(:controller) do
      described_class.new(request: request)
    end

    let(:authority) do
      persister.save(resource: FactoryBot.create(:concept,
        id: "test_id1",
        pref_label: "Label 1"))
    end
    let(:other_authority) do
      persister.save(resource: FactoryBot.create(:concept,
        id: "test_id2",
        pref_label: "Label 2"))
    end

    context "with an unknown media type" do
      let(:headers) { {"CONTENT_TYPE" => "application/fake"} }
      let(:body) { StringIO.new("") }

      it "gives a 415 status" do
        expect(controller.batch_update.first).to eq 415
      end
    end

    context "with batch of existing authority records" do
      let(:data) do
        [{id: authority.id.to_s, pref_label: "new_label_1"},
          {id: other_authority.id.to_s, pref_label: "new_label_2"}].to_json
      end
      let(:body) { StringIO.new(data) }

      it "gives a 204 no_content status" do
        expect(controller.batch_update.first).to eq 204
      end
    end

    context "with non-existing authority record" do
      let(:data) do
        [{id: "a_fade_id", pref_label: "new_label_1"}].to_json
      end
      let(:body) { StringIO.new(data) }

      it "gives a 404 status" do
        expect(controller.batch_update.first).to eq 404
      end
    end
  end

  describe "#batch_import" do
    subject(:controller) { described_class.new(request: request) }

    let(:csv_file) { "UCSD_authority_sample_2.csv" }
    let(:csv_file_path) { File.join(RSpec.configuration.fixture, csv_file) }
    let(:headers) { {"CONTENT_TYPE" => "text/csv"} }
    let(:body) { Rack::Test::UploadedFile.new(csv_file_path, "text/csv") }

    it "gives a 201 status" do
      expect(controller.batch_import.first).to eq 201
    end

    context "with a listener" do
      let(:listener) { FakeListener.new }

      before { Lark.config.event_stream.subscribe(listener) }

      it "adds an event to the stream" do
        expect { controller.batch_import }
          .to change(listener, :events)
          .to include have_attributes(id: "created")
      end
    end

    context "with an unknown media type" do
      let(:headers) { {"CONTENT_TYPE" => "application/fake"} }

      it "gives a 415 status" do
        expect(controller.batch_import.first).to eq 415
      end
    end
  end
end
