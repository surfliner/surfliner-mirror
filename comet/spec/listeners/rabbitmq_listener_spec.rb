# frozen_string_literal: true

require "rails_helper"

RSpec.describe RabbitmqListener, :rabbitmq do
  subject(:listener) { described_class.new(platform_name: :tidewater) }

  describe "#on_collection_publish" do
    let(:event) { Dry::Events::Event.new("collection.publish", {collection: collection}) }

    let(:collection) do
      Hyrax.persister.save(resource: Hyrax::PcdmCollection.new)
    end

    it "does not raise an error" do
      expect { listener.on_collection_publish(event) }.not_to raise_error
    end

    context "when the collection is unsaved" do
      it "is a no-op(?)"
    end

    context "when the collection has objects" do
      let(:objects) do
        opts = {member_of_collection_ids: [collection.id]}

        [Hyrax.persister.save(resource: GenericObject.new(opts)),
          Hyrax.persister.save(resource: GenericObject.new(opts)),
          Hyrax.persister.save(resource: GenericObject.new(opts))]
      end

      it "changes the object ACLs to include :discover for tidewater" do
        expect { listener.on_collection_publish(event) }
          .to change { objects.map { |o| Hyrax::AccessControlList.new(resource: o).permissions } }
          .to contain_exactly(include(have_attributes(mode: :discover, agent: "group/surfliner.tidewater")),
            include(have_attributes(mode: :discover, agent: "group/surfliner.tidewater")),
            include(have_attributes(mode: :discover, agent: "group/surfliner.tidewater")))
      end
    end
  end
end
