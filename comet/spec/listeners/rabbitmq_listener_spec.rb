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

    it "sets discovery permission for collection" do
      expect { listener.on_collection_publish(event) }
        .to change { Hyrax::AccessControlList.new(resource: collection).permissions }
        .to contain_exactly(have_attributes(mode: :discover, agent: "group/surfliner.tidewater"))
    end

    context "when the collection is unsaved" do
      let(:collection) { Hyrax::PcdmCollection.new }

      it "is a no-op(?)" do
        expect { listener.on_collection_publish(event) }
          .not_to change { Hyrax::AccessControlList.new(resource: collection).permissions }
          .from be_empty
      end
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

      context "when some objects are unpublishable" do
        subject(:listener) do
          described_class
            .new(platform_name: :tidewater, publisher_class: fake_publisher)
        end

        let(:fake_publisher) do
          Class.new do
            attr_reader :published

            def open_on(*)
              yield self
            end

            def append_access_control_to(**)
              :no_op
            end

            def publish(resource:)
              @published ||= []
              @published << resource

              raise DiscoveryPlatformPublisher::UnpublishableObject
            end
          end.new
        end

        it "attempts to publish all objects" do
          expect { listener.on_collection_publish(event) }
            .to change { fake_publisher.published }
            .to contain_exactly(*objects)
        end
      end
    end
  end
end
