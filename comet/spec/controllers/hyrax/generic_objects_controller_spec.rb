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
end
