# frozen_string_literal: true

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
DiscoveryPlatform = Struct.new(:name) do
  ##
  # @return [Hyrax::Group]
  def agent
    Hyrax::Group.new(name.to_s)
  end

  ##
  # @return [String]
  def routing_key
    "#{topic}.#{name}"
  end

  ##
  # @return [String]
  def topic
    ENV.fetch("RABBITMQ_TOPIC") { "surfliner.metadata" }
  end
end
