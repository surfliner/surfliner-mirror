# frozen_string_literal: true

class RabbitmqListener
  ##
  # @!attribute [rw] platform_name
  #   @return [Symbol]
  attr_accessor :platform_name

  ##
  # @param [Symbol] platform_name
  def initialize(platform_name:)
    self.platform_name = platform_name
  end

  def on_collection_publish(event)
    Hyrax.logger.debug("Pushing MQ events for collection publish with id #{event[:collection].id}")

    DiscoveryPlatformPublisher.open_on(platform_name) do |publisher|
      query_member_objects(collection: event[:collection]).each do |obj|
        publisher.publish(resource: obj)
      end
    end
  rescue => err
    Hyrax.logger.error(err)
  end

  private

  # Find objects in the collection
  def query_member_objects(collection:)
    Hyrax.query_service.find_inverse_references_by(resource: collection,
      property: "member_of_collection_ids",
      model: ::GenericObject)
  end
end
