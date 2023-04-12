# frozen_string_literal: true

require "rails_helper"

RSpec.describe Bulkrax::ValkyrieObjectFactory, :with_admin_set do
  subject(:object_factory) do
    described_class.new(attributes: attributes,
      source_identifier_value: source_identifier,
      work_identifier: work_identifier,
      user: user,
      klass: ::GenericObject)
  end

  let(:user) { User.find_or_create_by(email: "comet-admin@library.ucsb.edu") }
  let(:work_identifier) { "" }

  describe "#create" do
    context "with a visibility" do
      let(:attributes) do
        {title: "Test Import Title with Visibility",
         visibility: "open",
         source_identifier_value: "object_with_viz"}
      end

      let(:source_identifier) { "object_with_viz" }

      it "assigns the visibility" do
        object_factory.run!

        imported = Hyrax.query_service.find_all_of_model(model: GenericObject).first
        expect(imported)
          .to have_attributes(visibility: "open")
      end
    end
  end

  context "when work_identifier is empty" do
    let(:source_identifier) { "object_1" }
    let(:title) { "Test Bulkrax Import Title" }
    let(:alternative_title) { "Test Alternative Title" }
    let(:rights_statement) { "http://rightsstatements.org/vocab/NoC-US/1.0/" }
    let(:attributes) { {title: title, title_alternative: [alternative_title], rights_statement: rights_statement} }

    it "create object with metadata" do
      object_factory.run!

      object_imported = Hyrax.query_service.find_all_of_model(model: GenericObject).first

      expect(object_imported).to have_attributes(
        title: contain_exactly(title),
        alternate_ids: contain_exactly(source_identifier),
        rights_statement: contain_exactly(rights_statement)
      )
    end
  end

  context "when work_identifier matches an existing object" do
    let(:object) do
      FactoryBot.valkyrie_create(:generic_object,
        :with_index,
        title: ["Test Object"],
        title_alternative: ["Test Alternative Title"],
        alternate_ids: [source_identifier])
    end

    let(:source_identifier) { "object_2" }
    let(:title_updated) { "Test Bulkrax Import Title Update" }
    let(:alternative_title_updated) { "Test Alternative Title Added" }
    let(:rights_statement) { "http://rightsstatements.org/vocab/NoC-US/1.0/" }
    let(:work_identifier) { object.id }
    let(:attributes) do
      {
        title: title_updated,
        title_alternative: [alternative_title_updated],
        rights_statement: rights_statement,
        id: work_identifier,
        alternate_ids: [source_identifier]
      }
    end

    it "update object with metadata" do
      object_factory.run!

      objects = Hyrax.query_service.find_all_of_model(model: GenericObject)
      objects_updated = objects.select { |o| o.alternate_ids == [source_identifier] }

      expect(objects_updated.length).to eq 1
      expect(objects_updated.first.title).to eq [title_updated]
      expect(objects_updated.first.title_alternative).to eq [alternative_title_updated]
      expect(objects_updated.first.rights_statement).to eq [rights_statement]
    end
  end
end
