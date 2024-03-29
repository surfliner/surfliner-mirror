# frozen_string_literal: true

require "rails_helper"

RSpec.describe DiscoveryPlatformPublisher do
  subject(:publisher) { DiscoveryPlatformPublisher.new(platform: platform, broker: broker) }
  let(:platform) { DiscoveryPlatform.new(:tidewater) }
  let(:broker) { spy("Broker") }

  describe ".open_on" do
    it "yields an instance" do
      expect { |b| described_class.open_on(:tidewater, &b) }
        .to yield_with_args(an_instance_of(DiscoveryPlatformPublisher))
    end

    it "yields with the tidewater exchange" do
      expect { |b| described_class.open_on(:tidewater, &b) }
        .to yield_with_args(an_instance_of(DiscoveryPlatformPublisher))
    end

    it "yields with a broker on " do
      expect { |b| described_class.open_on(:tidewater, &b) }
        .to yield_with_args(have_attributes(broker: respond_to(:publish),
          platform: have_attributes(name: :tidewater)))
    end

    it "closes the broker", :rabbitmq do
      broker = nil
      described_class.open_on(:tidewater) { |publisher| broker = publisher.broker }

      expect(broker.channel).to be_closed
    end
  end

  describe "#publish" do
    let(:resource) do
      Hyrax.persister.save(resource: GenericObject.new(title: "Comet in Moominland"))
    end

    it "changes the resource ACLs" do
      expect { publisher.publish(resource: resource) }
        .to change { Hyrax::AccessControlList.new(resource: resource) }
        .to grant_access(:discover).on(resource).to(platform.agent)
    end

    it "publishes to the broker" do
      publisher.publish(resource: resource)

      expect(broker)
        .to have_received(:publish)
        .with(payload: include("\"status\":\"published\""),
          routing_key: platform.message_route.metadata_routing_key)
    end

    it "does not publish on successive calls" do
      publisher.publish(resource: resource)
      publisher.publish(resource: resource)
      publisher.publish(resource: resource)

      expect(broker).to have_received(:publish).once
    end

    context "when an ark is minted for a resource" do
      let(:ark) { "ark:/99999/fk4tq65d6k" }
      let(:resource) do
        Hyrax.persister.save(resource: GenericObject.new(title: "Comet in Moominland", ark: ark))
      end
      it "includes the ark in the payload" do
        publisher.publish(resource: resource)

        expect(broker)
          .to have_received(:publish)
          .with(payload: include("\"ark\":\"#{ark}\""),
            routing_key: platform.message_route.metadata_routing_key)
      end
    end

    context "when an ark is not minted for a resource" do
      let(:resource) do
        Hyrax.persister.save(resource: GenericObject.new(title: "Comet in Moominland"))
      end
      it "is not included in the payload" do
        publisher.publish(resource: resource)

        expect(broker)
          .not_to have_received(:publish)
          .with(payload: include("\"ark\""),
            routing_key: platform.message_route.metadata_routing_key)
      end
    end

    context "when the resource is unsaved" do
      let(:resource) { GenericObject.new }

      it "raises an error; cannot publish an unsaved resource" do
        expect { publisher.publish(resource: resource) }
          .to raise_error(ArgumentError)
      end
    end
  end

  describe "#unpublish" do
    let(:resource) do
      Hyrax.persister.save(resource: GenericObject.new(title: "Comet in Moominland"))
    end

    context "when the resource has already been published" do
      before do
        # Don’t use publisher.publish here to keep from sending extra messages
        # to the broker.
        acl = Hyrax::AccessControlList.new(resource: resource)
        acl.grant(:discover).to(platform.agent)
        acl.save
      end

      it "changes the resource ACLs" do
        expect { publisher.unpublish(resource: resource) }
          .to change { Hyrax::AccessControlList.new(resource: resource) }
          .to revoke_access(:discover).on(resource).from(platform.agent)
      end

      it "publishes to the broker" do
        publisher.unpublish(resource: resource)

        expect(broker)
          .to have_received(:publish)
          .with(payload: include("\"status\":\"unpublished\""),
            routing_key: platform.message_route.metadata_routing_key)
      end

      it "does not unpublish on successive calls" do
        publisher.unpublish(resource: resource)
        publisher.unpublish(resource: resource)
        publisher.unpublish(resource: resource)

        expect(broker).to have_received(:publish).once
      end
    end

    context "when the resource is unsaved" do
      let(:resource) { GenericObject.new }

      it "raises an error; cannot unpublish an unsaved resource" do
        expect { publisher.unpublish(resource: resource) }
          .to raise_error(ArgumentError)
      end
    end
  end

  describe "#update" do
    let(:resource) do
      Hyrax.persister.save(resource: GenericObject.new(title: "Comet in Moominland"))
    end

    context "when it has not been published" do
      it "does not unpublish on successive calls" do
        publisher.update(resource: resource)

        expect(broker).not_to have_received(:publish)
      end
    end

    context "when the resource has already been published" do
      before do
        acl = Hyrax::AccessControlList.new(resource: resource)
        acl.grant(:discover).to(platform.agent)
        acl.save
      end

      it "publishes to the broker" do
        publisher.update(resource: resource)

        expect(broker)
          .to have_received(:publish)
          .with(payload: include("\"status\":\"updated\""),
            routing_key: platform.message_route.metadata_routing_key)
      end
    end

    context "when the resource is unsaved" do
      let(:resource) { GenericObject.new }

      it "raises an error; cannot unpublish an unsaved resource" do
        expect { publisher.update(resource: resource) }
          .to raise_error(ArgumentError)
      end
    end
  end
end
