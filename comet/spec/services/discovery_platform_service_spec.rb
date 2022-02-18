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
  let(:url_base) { ENV.fetch("DISCOVER_PLATFORM_TIDEWATER_URL_BASE") { Rails.application.config.metadata_api_uri_base } }

  before { publisher.publish(resource: object) }

  it "gives the label and url for a link" do
    expect(described_class.call(object.id))
      .to include(["Tidewater", "#{url_base}/#{object.id}"])
  end
end
