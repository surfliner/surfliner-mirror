require "rails_helper"

RSpec.describe Bulkrax::ValkyrieObjectFactory, :with_admin_set do
  subject(:object_factory) do
    described_class.new(attributes: attributes,
      source_identifier_value: source_identifier,
      work_identifier: work_identifier,
      user: user,
      klass: klass,
      update_files: update_files)
  end

  let(:klass) { ::GenericObject }
  let(:update_files) { false }
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

    context "when creating a collection" do
      let(:klass) { ::Collection }

      let(:attributes) do
        {
          # admin_set_id: "",
          model: "Collection",
          source_identifier_value: "spec_collection",
          title: "A Test Collection"
        }
      end

      let(:source_identifier) { "spec_collection" }

      it "makes a collection" do
        object_factory.run!

        imported = Hyrax.query_service.find_all_of_model(model: Collection).first
        expect(imported)
          .to have_attributes(title: "A Test Collection")
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

  context "attaching files" do
    let(:s3_bucket) { ENV.fetch("STAGING_AREA_S3_BUCKET", "comet-staging-area-#{Rails.env}") }
    let(:file) { Tempfile.new("image.jpg").tap { |f| f.write("An image!") } }
    let(:s3_key) { "demo_files/demo.jpg" }
    let(:missing_s3_key) { "not/inbucket.jpg" }
    let(:fog_connection) { mock_fog_connection }
    let(:source_identifier) { "object_1" }
    let(:title) { "Test Bulkrax Import with missing file" }
    let(:attributes) do
      {
        title: title,
        "use:PreservationFile": [{url: s3_key}],
        "use:ServiceFile": [{url: missing_s3_key}]
      }
    end

    before do
      Rails.application.config.staging_area_s3_connection = fog_connection
      staging_area_upload(fog_connection: fog_connection,
        bucket: s3_bucket, s3_key: s3_key, source_file: file)
    end

    after do
      file = fog_connection.directories.new(key: s3_bucket).files.new(key: s3_key)
      file.destroy
    end

    it "does not attach files that don't exist in staging area s3 bucket" do
      expect(Hyrax.logger).to receive(:warn).with("Failed to load file #{missing_s3_key} from s3 bucket #{s3_bucket}")

      created_object = object_factory.run!

      fs = Hyrax.custom_queries.find_child_file_sets(resource: created_object).first
      attached_files = Hyrax.custom_queries.find_files(file_set: fs)

      expect(created_object.member_ids.size).to eq 1
      expect(attached_files.size).to eq 1
      expect(attached_files.first.title.first.to_s).to eq "demo.jpg"
      expect(attached_files.first.type.first).to eq Hyrax::FileMetadata::Use::PRESERVATION_FILE
    end
  end

  context "update_file" do
    let(:object) do
      FactoryBot.valkyrie_create(:generic_object,
        :with_index,
        title: ["Test Object"],
        title_alternative: ["Test Alternative Title"],
        alternate_ids: [source_identifier])
    end

    let(:update_files) { true }
    let(:source_identifier) { "object_3" }
    let(:title_updated) { "Test Bulkrax Import Update and replace Files" }
    let(:work_identifier) { object.id }

    let(:attributes) do
      {
        title: title_updated,
        id: work_identifier,
        alternate_ids: [source_identifier],
        remote_files: [{url: "demo_files/demo.jpg"}]
      }
    end

    let(:fog_connection) { mock_fog_connection }
    let(:s3_bucket) { ENV.fetch("STAGING_AREA_S3_BUCKET", "comet-staging-area-#{Rails.env}") }
    let(:file) { Tempfile.new("image.jpg").tap { |f| f.write("A fade image!") } }
    let(:s3_key) { "demo_files/demo.jpg" }

    before do
      Rails.application.config.staging_area_s3_connection = fog_connection

      staging_area_upload(fog_connection: fog_connection,
        bucket: s3_bucket, s3_key: s3_key, source_file: file)
    end

    after do
      file = fog_connection.directories.new(key: s3_bucket).files.new(key: s3_key)
      file.destroy
    end

    it "update object with metadata and files" do
      object_updated = object_factory.run!

      fs = Hyrax.custom_queries.find_child_file_sets(resource: object_updated).first
      use = Hyrax.custom_queries.find_files(file_set: fs).first.type.first

      expect(object_updated)
        .to have_attributes(title: contain_exactly(title_updated))
      expect(object_updated.member_ids.size).to eq 1
      expect(use).to eq Hyrax::FileMetadata::Use::ORIGINAL_FILE
    end

    context "with pcdm:use values" do
      let(:attributes) do
        {
          :title => title_updated,
          :id => work_identifier,
          :alternate_ids => [source_identifier],
          "use:PreservationFile" => [{url: "demo_files/demo.jpg"}]
        }
      end

      it "updates object with metadata and files with pcdm:use values" do
        object_updated = object_factory.run!

        fs = Hyrax.custom_queries.find_child_file_sets(resource: object_updated).first
        use = Hyrax.custom_queries.find_files(file_set: fs).first.type.first

        expect(object_updated)
          .to have_attributes(title: contain_exactly(title_updated))
        expect(object_updated.member_ids.size).to eq 1
        expect(use).to eq Hyrax::FileMetadata::Use::PRESERVATION_FILE
      end
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
