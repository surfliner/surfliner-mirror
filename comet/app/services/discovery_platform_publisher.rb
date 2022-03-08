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
  # Opens a broker and yields a block to publish multiple resources.
  #
  # The broker is closed following the execution of the block.
  def self.open_on(name, &block)
    platform = DiscoveryPlatform.new(name)
    broker = MessageBroker.for(topic: platform.message_route.metadata_topic)

    yield new(platform: platform, broker: broker)

    broker.close
  end

  ##
  # The URL for the API endpoint corresponding to the given resource.
  #
  # @return [String]
  def self.api_uri_for(resource, base_uri: Rails.application.config.metadata_api_uri_base)
    "#{base_uri}/#{resource.id}"
  end

  ##
  # Publishes the resource if it has not already been published before.
  #
  # Determining whether a resource has been published is done by checking its
  # ACLs. At present there is no way to republish a resource (resend a message
  # via the message broker) which has already been published (already has the
  # appropriate ACL). There is also not a means of unpublishing (unsetting the
  # access controls or signalling an unpublish event on the message broker).
  # Hopefully this functionality will be implemented in the future.
  #
  # @param [Hyrax::Resource] resource  the resource to publish
  def publish(resource:)
    raise(UnpublishableObject) unless resource.persisted?
    Hyrax.logger.debug { "Publishing object with id #{resource.id}" }
    append_access_control_to(resource: resource) &&
      broker.publish(payload: payload_for(resource, "published"), routing_key: platform.message_route.metadata_routing_key)
  end

  ##
  # Unpublishes the object resource if it has been published, which is determined by
  # whether a resource has been published by checking its ACLs, and remove it for unpublish.
  #
  # @param [Hyrax::Resource] resource  the resource to unpublish
  def unpublish(resource:)
    raise(UnpublishableObject) unless resource.persisted?

    Hyrax.logger.debug { "Unpublishing object with id #{resource.id}" }
    revoke_access_control_for(resource: resource) &&
      broker.publish(payload: payload_for(resource, "unpublished"), routing_key: platform.message_route.metadata_routing_key)
  end

  class UnpublishableObject < ArgumentError; end

  private

  ##
  # @return [Boolean] true if the ACL was not already present, and has been
  #   added; false otherwise.
  def append_access_control_to(resource:)
    acl = Hyrax::AccessControlList.new(resource: resource)

    # two troublesome things here:
    #   - `Valkyrie::ChangeSet` regards permissions as changed after setting
    #     them, even if they are set to the original value. i wanted this to
    #     be `#pending_changes?` on the ACL, but no go.
    #   - Hyrax::Group doesn't know it's own ACL key. planning to fix that
    #     upstream so the string construction can be `platform.agent.user_key`
    #     instead.
    return if acl.permissions.any? do |permission|
      permission.mode == :discover &&
        permission.agent == "#{Hyrax::Group.name_prefix}#{platform.agent.name}"
    end

    acl.grant(:discover).to(platform.agent)
    acl.save
  end

  ##
  # Remove the discover platform group form ACL
  #
  # Troublesome: Hyrax ACL.revoke(:discover).from(:group) does not seem to work as expected.
  #
  # @return [Boolean] true if the ACL has been removed and saved successfully; otherwise false.
  def revoke_access_control_for(resource:)
    acl = Hyrax::AccessControlList.new(resource: resource)

    new_permissions = acl.permissions.to_a.delete_if { |permission|
      permission.mode.to_sym == :discover &&
        permission.agent == "#{Hyrax::Group.name_prefix}#{platform.agent.name}"
    }

    acl.permissions = new_permissions
    acl.save
  end

  ##
  # @return [String] a JSON payload
  def payload_for(resource, status)
    {resourceUrl: self.class.api_uri_for(resource),
     status: status,
     time_stamp: resource.date_modified || resource.updated_at}.to_json
  end
end
