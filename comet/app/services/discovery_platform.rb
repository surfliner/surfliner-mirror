# frozen_string_literal: true

DISCOVERY_PLATFORM_GROUP_NAME_PREFIX = "surfliner"

##
# Provides configuration for integration with discovery platforms.
#
# Comet offers systems for users to control visibility of resources in a variety
# of discovery front-ends. This gives a single interface for options that
# identify a given discovery platform throughout comet's internals and on its
# message queues.
#
# These options include a unique `#name` for the platform (as a Symbol), the
# message queue topics and routing keys relevant to the platform, and the
# agent that identifies the platform in ACLs.
class DiscoveryPlatform
  ##
  # @!attribute [rw] name
  #   @return [Symbol]
  attr_accessor :name

  ##
  # @param name [#to_sym]
  def initialize(name)
    self.name = name.to_sym
  end

  ##
  # @return [Hyrax::Group]
  def agent
    Hyrax::Group.new("#{DISCOVERY_PLATFORM_GROUP_NAME_PREFIX}:#{name}")
  end

  ##
  # @return [DiscoveryPlatform::MessageRoute]
  def message_route
    @message_route ||= MessageRoute.new(self)
  end

  MessageRoute = Struct.new(:platform) do
    ##
    # @return [String]
    def metadata_routing_key
      "#{metadata_topic}.#{platform.name}"
    end

    ##
    # @return [String]
    def metadata_topic
      ENV.fetch("RABBITMQ_TOPIC", "surfliner.metadata")
    end
  end
end
