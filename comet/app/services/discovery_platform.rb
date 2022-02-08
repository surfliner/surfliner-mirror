# frozen_string_literal: true

DiscoveryPlatform = Struct.new(:name) do
  def routing_key
    "#{topic}.#{name}"
  end

  def topic
    ENV.fetch("RABBITMQ_TOPIC") { "surfliner.metadata" }
  end
end
