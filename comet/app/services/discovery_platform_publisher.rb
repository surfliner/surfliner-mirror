# frozen_string_literal: true

##
# Handles making objects visible to a discovery system, "publishing"
# them.
#
# This is normally a two step process:
#
#   - update the object's ACLs to allow discover access for the platform
#   - publish messages on the broker
#
# @note we have some semantic overload on "publish".
class DiscoveryPlatformPublisher
  ##
  # @!attribute [rw] broker
  #   @return [MessageBroker]
  # @!attribute [rw] platform
  #   @return [DiscoveryPlatform]
  attr_accessor :broker, :platform

  ##
  # @param [DiscoveryPlatform] platform
  # @param [MessageBroker] broker
  def initialize(platform:, broker:)
    @broker = broker
    @platform = platform
  end

  ##
  # opens a broker and yields a block to publish multiple resources
  def self.open_on(name, &block)
    platform = DiscoveryPlatform.new(name)
    broker = MessageBroker.for(topic: platform.message_route.metadata_topic)

    yield new(platform: platform, broker: broker)

    broker.close
  end

  ##
  # @param [Hyrax::Resource] resource  the resource to publish
  def publish(resource:)
    Hyrax.logger.debug { "Publishing object with id #{resource.id}" }
    append_access_control_to(resource: resource) &&
      broker.publish(payload: payload_for(resource), routing_key: platform.message_route.metadata_routing_key)
  end

  private

  ##
  # @return [String]
  def api_uri_for(resource, base_uri: Rails.application.config.metadata_api_uri_base)
    "#{base_uri}/#{resource.id}"
  end

  ##
  # @return [Boolean] true if the ACL was not already present, and has been
  #   added; false otherwise.
  def append_access_control_to(resource:)
    acl = Hyrax::AccessControlList(resource)
    acl.grant(:discover).to(platform.agent)
    acl.save
  end

  ##
  # @return [String] a JSON payload
  def payload_for(resource)
    {resourceUrl: api_uri_for(resource),
     status: "published",
     time_stamp: resource.date_modified || resource.updated_at}.to_json
  end
end
