require "bunny"
require "net/http"
require "logger"

module Shoreline
  class Consumer
    attr_reader :connection, :importer, :logger, :tracer

    def initialize(tracer:, importer: Importer, logger: Logger.new($stdout))
      @connection = Connection.new(logger: logger)
      @importer = importer
      @logger = logger
      @tracer = tracer
    end

    def self.run(tracer:, importer: Importer, logger: Logger.new($stdout))
      new(tracer: tracer, importer: importer, logger: logger).run
    end

    def run
      connection.open do |queue|
        queue.subscribe(block: true) do |_delivery_info, _properties, payload|
          tracer.in_span("shoreline consumer message") do |span|
            logger.info(" [  ] message received with payload: #{payload}")

            payload_data = JSON.parse(payload)
            payload_resource_url = payload_data["resourceUrl"]
            raise "Payload resourceUrl is not defined" unless payload_resource_url

            payload_status = payload_data["status"]
            raise "Payload status is not defined" unless payload_status
            logger.debug("Payload status for #{payload_resource_url} is #{payload_status}")

            span.add_attributes(
              "surfliner.message.status" => payload_status.to_s,
              "surfliner.resource_uri" => payload_resource_url.to_s
            )

            uri = URI(payload_resource_url)

            process_resource_payload(uri, payload)
          end
        end
      end
    end

    def process_resource(uri, status)
      span = OpenTelemetry::Trace.current_span

      case status.to_s
      when "published", "updated"
        record = Record.load(uri, logger: logger)
        logger.info("Persisting item #{uri}")
        logger.debug("#{uri} responded with #{record.data}")

        # TODO: teach the importer how to handle multiple shapefiles per record?
        importer.ingest(metadata: record.metadata, shapefile_url: record.file_urls.first)
      when "unpublished", "deleted"
        logger.info("Deleting item #{uri}")
        resource_id = uri.split("/").last
        importer.delete(id: resource_id)
      else
        msg = "Invalid payload status '#{status}' received for #{uri}"
        logger.error(msg)
        span.status = OpenTelemetry::Trace::Status.error(msg)
      end
    rescue => e
      logger.error("Error: #{e}")
      span.record_exception(e)
      span.status = OpenTelemetry::Trace::Status.error("Unhandled exception of type: #{e.class}")
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
