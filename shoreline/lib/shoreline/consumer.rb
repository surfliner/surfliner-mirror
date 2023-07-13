require "bunny"
require "net/http"
require "logger"

module Shoreline
  class Consumer
    attr_reader :connection, :logger

    def initialize(logger: Logger.new($stdout))
      @connection = Connection.new(logger: logger)
      @logger = logger
    end

    class Connection
      attr_reader :channel, :connection, :connection_url, :exchange, :logger, :queue

      def initialize(logger: Logger.new($stdout))
        @logger = logger
        rabbitmq_host = ENV.fetch("RABBITMQ_HOST")
        rabbitmq_password = ENV.fetch("RABBITMQ_PASSWORD")
        rabbitmq_port = ENV.fetch("RABBITMQ_NODE_PORT_NUMBER")
        rabbitmq_user = ENV.fetch("RABBITMQ_USERNAME")

        @routing_key = ENV.fetch("RABBITMQ_SHORELINE_ROUTING_KEY")
        @queue = ENV.fetch("RABBITMQ_QUEUE")
        @topic = ENV.fetch("RABBITMQ_TOPIC")

        @connection_url = URI("amqp://#{rabbitmq_user}:#{rabbitmq_password}@#{rabbitmq_host}:#{rabbitmq_port}")
      end

      def connect
        raise "RabbitMQ connection #{connection} already open." if
          connection&.status == :open

        logger.info("Rabbitmq message broker connection url: #{redacted_url}")
        @connection = Bunny.new(connection_url.to_s, logger: logger)
        connection.start
        @channel = connection.create_channel
        @exchange = channel.topic(@topic, auto_delete: true)
        @queue = channel.queue(@queue, durable: true)
        queue.bind(exchange, routing_key: @routing_key)

        self
      rescue Bunny::TCPConnectionFailed => err
        logger.error("Connection to #{redacted_url} failed")
        raise err
      rescue Bunny::PossibleAuthenticationFailureError => err
        logger.error("Failed to authenticate to #{redaceted_url}")
        raise err
      end

      def open
        connect
        yield queue
      ensure
        close
      end

      def close
        channel&.close
      ensure
        connection&.close
      end

      private

      def redacted_url
        "#{connection_url.scheme}://#{connection_url.user}:REDACTED@" \
        "#{connection_url.host}:#{connection_url.port}"
      end
    end
  end
end
