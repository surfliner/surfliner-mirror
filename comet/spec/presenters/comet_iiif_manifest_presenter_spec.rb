# frozen_string_literal: true

require "rails_helper"

RSpec.describe CometIiifManifestPresenter do
  subject(:presenter) { described_class.new(work) }
  let(:work) { GenericObject.new }

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

  describe "#file_set_presenters" do
    let(:file_set) { Hyrax.persister.save(resource: Hyrax::FileSet.new) }
    let(:work) { GenericObject.new(member_ids: file_set.id) }

    # file sets are read from the index; is that what we want?
    before { Hyrax.index_adapter.save(resource: file_set) }

    it "presents the file sets" do
      expect(presenter.file_set_presenters)
        .to contain_exactly(have_attributes(id: file_set.id))
    end
  end

  describe "#manifest_metadata" do
    it "excludes empty metadata" do
      expect(presenter.manifest_metadata).to be_empty
    end

    context "with some metadata" do
      let(:work) do
        Hyrax.persister.save(resource:
          GenericObject.new(
            title: ["Comet in Moominland", "Mumintrollet på kometjakt"],
            creator: "Tove Jansson"
          ))
      end

      it "includes configured metadata" do
        expect(presenter.manifest_metadata)
          .to contain_exactly({"label" => "Title", "value" => ["Comet in Moominland", "Mumintrollet på kometjakt"]},
            {"label" => "Creator", "value" => ["Tove Jansson"]})
      end
    end

    context "with a configured object type" do
      let(:work) { FactoryBot.valkyrie_create(:geo_object) }

      it "includes configured metadata" do
        expect(presenter.manifest_metadata)
          .to contain_exactly({"label" => "Title", "value" => work.title})
      end
    end
  end

  describe "#manifest_url" do
    it "gives an empty string for an unpersisted object" do
      expect(presenter.manifest_url).to be_empty
    end

    context "with a persisted work" do
      let(:work) { Hyrax.persister.save(resource: GenericObject.new) }

      it "builds a url from the manifest path and work id " do
        expect(presenter.manifest_url).to include "concern/generic_objects/#{work.id}/manifest"
      end
    end
  end
end
