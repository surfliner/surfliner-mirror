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

    class Record
      DEFAULT_JSONLD_PROFILE = "tag:surfliner.gitlab.io,2022:api/aardvark"

      def self.load(uri, logger: Logger.new($stdout))
        new(data: JSON.parse(get(uri, logger: logger)))
      end

      def self.get(uri, logger: Logger.new($stdout))
        uri = URI(uri)
        jsonld_profile = ENV.fetch("SHORELINE_METADATA_PROFILE") { DEFAULT_JSONLD_PROFILE }

        req = Net::HTTP::Get.new(uri)
        req["Accept"] = "application/ld+json;profile=\"#{jsonld_profile}\""
        req["User-Agent"] = ENV.fetch("USER_AGENT_PRODUCT_NAME") { "surfliner.shoreline" }
        logger.debug "Querying #{uri} ..."

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") { |http|
          http.request(req)
        }

        case res
        when Net::HTTPSuccess
          res.body
        when Net::HTTPRedirection
          logger.debug "Got a 30x response: #{res}"
          fetch(uri: URI(res["location"]), logger: logger)
        else
          logger.debug "Got a non-success HTTP response:"
          logger.debug res.inspect

          raise "Failed to fetch data from Superskunk"
        end
      end

      attr_reader :data

      def initialize(data:)
        @data = data
      end

      def id
        metadata["id"]
      end

      def metadata
        data.except("_file_urls")
      end

      ##
      # @return [Array<String>]
      def file_urls
        Array(data["_file_urls"])
      end
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
