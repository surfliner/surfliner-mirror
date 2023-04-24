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
    let(:rights_statement) do
      RDF::Literal(
        "http://rightsstatements.org/vocab/NoC-US/1.0/",
        datatype: RDF::XSD.anyURI
      )
    end
    let(:attributes) { {title: title, title_alternative: [alternative_title], rights_statement: rights_statement} }

    before do
      setup_workflow_for(user)
      attributes[:admin_set_id] = Hyrax.query_service.find_all_of_model(model: Hyrax::AdministrativeSet)
        .find { |p| p.title.include?("Test Project") }.id
    end

    it "create object with metadata" do
      object_imported = object_factory.run!

      expect(object_imported).to have_attributes(
        title: contain_exactly(title),
        alternate_ids: contain_exactly(source_identifier),
        rights_statement: contain_exactly(rights_statement)
      )
    end

    it "create object in workflow" do
      object_imported = object_factory.run!

      workflow_object = Sipity::Entity(Hyrax.query_service.find_by(id: object_imported.id))

      expect(workflow_object.workflow_state).to have_attributes name: "in_review"
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
    let(:rights_statement) do
      RDF::Literal(
        "http://rightsstatements.org/vocab/NoC-US/1.0/",
        datatype: RDF::XSD.anyURI
      )
    end
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
      object_updated = object_factory.run!

      expect(object_updated)
        .to have_attributes(title: contain_exactly(title_updated),
          title_alternative: contain_exactly(alternative_title_updated),
          rights_statement:  contain_exactly(rights_statement))
    end
  end

  describe "#schema_properties" do
    let(:generic_properties) { Bulkrax::ValkyrieObjectFactory.schema_properties(::GenericObject) }
    let(:geospatial_properties) { Bulkrax::ValkyrieObjectFactory.schema_properties(::GeospatialObject) }

    context "with GenericObject" do
      let(:generic_object) { GenericObject.new }

      it "being responded to GenericObject instant" do
        generic_properties.each do |pro|
          expect(generic_object.respond_to?(pro))
        end
      end
    end

    context "with GeospatialObject" do
      let(:geospatial_object) { GeospatialObject.new }

      it "being responded to GeospatialObject instant" do
        geospatial_properties.each do |pro|
          expect(geospatial_object.respond_to?(pro))
        end
      end
    end
  end
end
