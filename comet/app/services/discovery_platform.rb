# frozen_string_literal: true

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
