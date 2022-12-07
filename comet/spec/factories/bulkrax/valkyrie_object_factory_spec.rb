# frozen_string_literal: true

require "rails_helper"

RSpec.describe Bulkrax::ValkyrieObjectFactory, storage_adapter: :memory, metadata_adapter: :test_adapter do
  subject(:object_factory) do
    described_class.new(attributes: attributes,
      source_identifier_value: source_identifier,
      work_identifier: work_identifier,
      user: user,
      klass: ::GenericObject)
  end

  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }

  describe "create" do
    let(:work_identifier) { "" }
    let(:source_identifier) { "object_1" }
    let(:title) { "Test Bulkrax Import Title" }
    let(:alternative_title) { "Test Alternative Title" }
    let(:attributes) { {title: title, title_alternative: [alternative_title]} }

    it "create object with metadata" do
      object_factory.run!

      objects = Hyrax.query_service.find_all_of_model(model: GenericObject)
      object_imported = objects.find { |o| o.alternate_ids == [source_identifier] }

      expect(object_imported.title_alternative).to eq [alternative_title]
    end
  end

  describe "update" do
    let(:source_identifier) { "object_2" }
    let(:title_updated) { "Test Bulkrax Import Title Update" }
    let(:alternative_title_updated) { "Test Alternative Title Added" }

    let(:object) {
      Hyrax.persister.save(resource: GenericObject.new(title: ["Test Object"],
        title_alternative: ["Test Alternative Title"],
        alternate_ids: [source_identifier]))
    }
    let(:work_identifier) { object.id }
    let(:attributes) { {title: title_updated, title_alternative: [alternative_title_updated], id: work_identifier, alternate_ids: [source_identifier]} }

    before { Hyrax.index_adapter.save(resource: object) }
    it "update object with metadata" do
      object_factory.run!

      objects = Hyrax.query_service.find_all_of_model(model: GenericObject)
      objects_updated = objects.select { |o| o.alternate_ids == [source_identifier] }

      expect(objects_updated.length).to eq 1
      expect(objects_updated.first.title).to eq [title_updated]
      expect(objects_updated.first.title_alternative).to eq [alternative_title_updated]
    end
  end
end
