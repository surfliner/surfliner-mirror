# frozen_string_literal: true

require "rails_helper"
require "hyrax/specs/spy_listener"

RSpec.describe InlineBatchUploadGeodataHandler, storage_adapter: :memory do
  subject(:service) { described_class.new(work: object) }

  let(:file) { Rails.root.join("spec", "fixtures", "shape.shp") }
  let(:file_2) { Rails.root.join("spec", "fixtures", "staging_area", "demo_files", "demo.jpg") }
  let(:local_file) { BatchUploadsControllerBehavior::StagingAreaFile.new(path: File.dirname(file), filename: File.basename(file), file_use: :geoshape_file) }
  let(:local_file_2) { BatchUploadsControllerBehavior::StagingAreaFile.new(path: File.dirname(file_2), filename: File.basename(file_2)) }
  let(:object) { Hyrax.persister.save(resource: GenericObject.new) }
  let(:upload) { BatchUploadFile.new(user: user, file: local_file) }
  let(:uploads) { [upload, BatchUploadFile.new(user: user, file: local_file_2)] }
  let(:user) { User.create(email: "moomin@example.com") }

  describe "#attach" do
    let(:listener) { Hyrax::Specs::AppendingSpyListener.new }
    before { Hyrax.publisher.subscribe(listener) }
    after { Hyrax.publisher.unsubscribe(listener) }

    context "after adding files" do
      before { service.add(files: uploads) }

      it "assigns only one FileSet id synchronously" do
        expect { service.attach }
          .to change { object.member_ids }
          .to contain_exactly(an_instance_of(Valkyrie::ID))
      end

      it "adds file members to the FileSet" do
        expect { service.attach }
          .to change { Hyrax.query_service.find_members(resource: object).flat_map(&:file_ids) }
          .to contain_exactly(an_instance_of(Valkyrie::ID),
            an_instance_of(Valkyrie::ID))
      end

      it "creates persisted filesets" do
        service.attach

        expect(Hyrax.custom_queries.find_child_file_sets(resource: object))
          .to contain_exactly(be_persisted)
      end

      it "publishes object.file.uploaded event for files" do
        expect { service.attach }
          .to change { listener.object_file_uploaded.map(&:payload) }
          .from(be_empty)
          .to contain_exactly(include(metadata: an_instance_of(Hyrax::FileMetadata)),
            include(metadata: an_instance_of(Hyrax::FileMetadata)))
      end

      it "publishes an object.metadata.updated event for one file set, plus the parent" do
        expect { service.attach }
          .to change { listener.object_metadata_updated.map(&:payload) }
          .from(be_empty)
          .to contain_exactly(include(object: object, user: user),
            include(object: an_instance_of(Hyrax::FileSet), user: user))
      end

      it "publishes exactly one file_set.attached events" do
        expect { service.attach }
          .to change { listener.file_set_attached.map(&:payload) }
          .from(be_empty)
          .to contain_exactly(include(file_set: an_instance_of(Hyrax::FileSet)))
      end

      it "publishes file_metadata.updated events for all files" do
        expect { service.attach }
          .to change { listener.file_metadata_updated.map(&:payload) }
          .from(be_empty)
          .to contain_exactly(include(metadata: an_instance_of(Hyrax::FileMetadata), user: user),
            include(metadata: an_instance_of(Hyrax::FileMetadata), user: user))
      end

      context "with object permissions" do
        before do
          acl = Hyrax::AccessControlList.new(resource: object)
          acl.grant(:read).to(Hyrax::Group.new("public"))
          acl.save
        end

        it "adds permissions to FileSet" do
          service.attach
          file_set = listener.file_set_attached.first.payload[:file_set]
          acl = Hyrax::AccessControlList(file_set)

          expect(acl.permissions)
            .to include(have_attributes(mode: :read, agent: "group/public"))
        end

        it "adds permissions to FileMetadata" do
          service.attach
          metadata = listener.file_metadata_updated.first.payload[:metadata]
          acl = Hyrax::AccessControlList(metadata)

          expect(acl.permissions)
            .to include(have_attributes(mode: :read, agent: "group/public"))
        end
      end
    end
  end
end
