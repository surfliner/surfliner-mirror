# frozen_string_literal: true

##
# A message broker with RabbitMQ/bunny for publishing
class MessageBroker
  attr_accessor :connection, :channel, :exchange

  ##
  # Constructor
  # @param connection [Bunny::Session]
  # @param topic [String] - the topic
  def initialize(topic:, connection: Rails.application.config.rabbitmq_connection)
    @connection = connection

    @channel = @connection.create_channel
    @channel.on_error do |ch, close|
      Hyrax.logger.error "Error on channel creation: #{ch}"
    end
    @exchange = channel.topic(topic, auto_delete: true)
  end

  ##
  # Publish message to exchange for all subscribers
  def publish(payload:, routing_key:)
    exchange.publish(payload, routing_key: routing_key)
  end

  ##
  # Close the channel
  def close
    @channel.close
  end
end
