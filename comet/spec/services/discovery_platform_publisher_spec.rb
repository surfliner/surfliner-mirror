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
        .with(payload: an_instance_of(String),
          routing_key: platform.message_route.metadata_routing_key)
    end

    it "does not publish on successive calls" do
      publisher.publish(resource: resource)
      publisher.publish(resource: resource)
      publisher.publish(resource: resource)

      expect(broker).to have_received(:publish).once
    end

    context "when the resource is unsaved" do
      let(:resource) { GenericObject.new }

      it "raises an error; cannot publish an unsaved resource" do
        expect { publisher.publish(resource: resource) }
          .to raise_error(ArgumentError)
      end
    end
  end
end
