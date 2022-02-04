# frozen_string_literal: true

class TidewaterRabbitmqListener
  attr_accessor :connection, :topic, :routing_key, :url_base

  def initialize(connection: Rails.application.config.rabbitmq_connection,
    topic: ENV.fetch("RABBITMQ_TOPIC", "surfliner.metadata"),
    routing_key: ENV.fetch("RABBITMQ_TIDEWATER_ROUTING_KEY", "surfliner.metadata.tidewater"),
    url_base: ENV.fetch("METADATA_API_URL_BASE", "http://localhost:3000/concern/generic_objects"))
    @connection = connection
    @topic = topic
    @routing_key = routing_key
    @url_base = url_base
  end

  def on_collection_publish(event)
    Hyrax.logger.debug("Pushing MQ events for collection publish with id #{event[:collection].id}")

    broker = MessageBroker.new(connection: connection, topic: topic)

    query_member_objects(collection: event[:collection]).each do |obj|
      payload = payloads(obj)
      broker.publish(payload: payload.to_json, routing_key: routing_key)

      acl = Hyrax::AccessControlList(obj)
      acl.grant(:discover).to(Hyrax::Group.new("tidewater"))
      acl.save

      Hyrax.logger.debug("Published object with id #{obj.id}: payload => #{payload.to_json}")
    end
  rescue => err
    Hyrax.logger.error(err)
  ensure
    broker.close
  end

  private

  # Find objects in the collection
  def query_member_objects(collection:)
    Hyrax.query_service.find_inverse_references_by(resource: collection,
      property: "member_of_collection_ids",
      model: ::GenericObject)
  end

  def payloads(resource)
    {}.tap do |pro|
      pro[:resourceUrl] = "#{url_base}/#{resource.id}"
      pro[:status] = "published"
      pro[:timestamp] = resource.date_modified.nil? ? resource.updated_at : resource.date_modified
    end
  end
end
