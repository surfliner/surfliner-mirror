# frozen_string_literal: true

require "rails_helper"

RSpec.describe DiscoveryPlatformService, :rabbitmq do
  subject(:publisher) { DiscoveryPlatformPublisher.new(platform: platform, broker: broker) }
  let(:platform) { DiscoveryPlatform.new(:tidewater) }
  let(:broker) { MessageBroker.for(topic: platform.message_route.metadata_topic) }
  let(:object) do
    obj = ::GenericObject.new(title: ["Test object for discovery platform"])
    Hyrax.persister.save(resource: obj)
  end

  before { publisher.publish(resource: object) }

  it "gives the label and url for a link" do
    expect(described_class.call(object.id))
      .to include(["Tidewater", "#{Rails.application.config.tidewater_uri_base}/#{object.id}"])
  end
end
