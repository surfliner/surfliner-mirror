# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hyrax::GenericObjectsController, storage_adapter: :memory, metadata_adapter: :test_adapter do
  let(:user) { User.create(email: "moomin@example.com") }

  describe "#create" do
    context "when assigning a collection relationship" do
      let(:collection_type) { Hyrax::CollectionType.create(title: "Spec Type") }
      let(:collection) {
        Hyrax::PcdmCollection.new(title: "Spec Type",
          collection_type_gid: collection_type.to_global_id)
      }

      it "persists the collection id for the object" do
        sign_in user

        persisted_collection = Hyrax.persister.save(resource: collection)
        collection_id = persisted_collection.id

        post :create, params: {generic_object: {title: "Test for #{collection_id}",
                                                language: [""],
                                                title_alternative: [""],
                                                title_filing: [""],
                                                member_of_collections_attributes: {"0" => {"id" => collection_id.to_s, "_destroy" => "false"}},
                                                visibility: "restricted",
                                                member_of_collection_ids: ""}}

        gobjs = Hyrax.query_service.find_all_of_model(model: GenericObject)
        persisted_object = gobjs.find do |gob|
          gob.title == ["Test for #{collection_id}"]
        end

        expect(persisted_object.member_of_collection_ids).to eq([collection_id])
      end
    end
  end

  describe "#manifest" do
    let(:object) { Hyrax.persister.save(resource: GenericObject.new(title: "Comet in Moominland")) }

    before do
      sign_in user

      acl = Hyrax::AccessControlList.new(resource: object)
      acl.grant(:read).to(user)
      acl.save

      Hyrax.index_adapter.save(resource: object)
    end

    it "displays manifest metadata" do
      get :manifest, params: {id: object.id, format: :json}
      expect(response.body).to include "Comet in Moominland"
    end

    context "with file members" do
      let(:upload_id) { Valkyrie::ID.new("fake://1") }

      let(:file_set) do
        Hyrax.persister.save(resource: Hyrax::FileSet.new(file_ids: [upload_id]))
      end

      let(:file_metadata) do
        Hyrax::FileMetadata.new(mime_type: "image/jpeg",
          file_set_id: file_set.id,
          file_identifier: upload_id,
          type: [::Valkyrie::Vocab::PCDMUse.OriginalFile])
      end

      let(:object) do
        resource = GenericObject.new(member_ids: [file_set.id], rendering_ids: [file_set.id])
        Hyrax.persister.save(resource: resource)
      end

      before do
        Hyrax.persister.save(resource: file_metadata)
        acl = Hyrax::AccessControlList.new(resource: file_set)
        acl.grant(:read).to(user)
        acl.save

        Hyrax.index_adapter.save(resource: file_set)
      end

      it "includes a canvas for the file_set" do
        get :manifest, params: {id: object.id, format: :json}

        expect(response.body).to include "sc:Canvas", file_set.id
      end
    end
  end
end
