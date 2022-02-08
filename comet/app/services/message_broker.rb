# frozen_string_literal: true

##
# A message broker with RabbitMQ/bunny for publishing
class MessageBroker
  attr_accessor :connection, :channel, :exchange

  ##
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

  def self.for(topic:, connection: nil)
    if Rails.application.config.use_rabbitmq
      conn = connection || Rails.application.config.rabbitmq_connection
      new(topic: topic, connection: conn)
    else
      NullBroker.new(topic: topic)
    end
  end

  ##
  # Publish message to exchange for all subscribers
  def publish(payload:, routing_key:)
    Hyrax.logger.debug { "Publishing to #{routing_key} with payload #{payload}" }
    exchange.publish(payload, routing_key: routing_key)
  end

  ##
  # Close the channel
  def close
    @channel.close
  end

  class NullBroker
    def initialize(topic:, connection: nil)
      @topic = topic
    end

    def publish(*args)
      Hyrax.logger.debug("Not publishing #{args} to #{@topic}; using NullBroker.")
    end

    def close
      Hyrax.logger.debug("Not closing message broker; using NullBroker.")
    end
  end
end
