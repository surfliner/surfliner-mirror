# frozen_string_literal: true

##
# An event listener for publishing to RabbitMQ.
#
# Listeners have a `platform_name` which is used to generate the routing key for
# the RabbitMQ message, in conjunction with the `RABBITMQ_TOPIC` environment
# variable.
#
# Listeners should be subscribed to `Hyrax.publisher` in an initializer;
# to add a new platform, simply subscribe a new listener with an appropriate
# product name.
#
# @example subscribe a new listener
#    Hyrax.publisher.subscribe(RabbitmqListener.new(platform_name: :my_platform))
#
# @note This is not actually Rabbitmq‐specific; it could conceivably be used
#   with any discovery platform publisher regardless of what its message broker
#   is. It probably needs a rename.
#
# @see https://dry-rb.org/gems/dry-events/
class RabbitmqListener
  ##
  # @!attribute [rw] platform_name
  #   @return [Symbol]
  attr_accessor :platform_name

  ##
  # @param platform_name [Symbol]
  def initialize(platform_name:)
    self.platform_name = platform_name
  end

  ##
  # Opens a platform publisher for this platform and publishes each member of
  # the collection specified in the event.
  #
  # This is a Dry Events event listener. The provided event should have a
  # :collection key which points to a Hyrax::PcdmCollection.
  #
  # @see https://dry-rb.org/gems/dry-events/
  #
  # @param event [{:collection => Hyrax::PcdmCollection}]
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

  ##
  # Handles object unpublish event.
  # This is a Dry Events event listener. The provided event should have a
  # :object key for the object that need to unpublish.
  #
  # @param event [{:object => GenericObject}]
  def on_object_unpublish(event)
    Hyrax.logger.debug("Pushing MQ events to unpublish object with id #{event[:object].id}")

    DiscoveryPlatformPublisher.open_on(platform_name) do |publisher|
      publisher.unpublish(resource: event[:object])
    end
  rescue => err
    Hyrax.logger.error(err)
  end

  private

  ##
  # Finds the objects in the collection.
  #
  # @param collection [Hyrax::PcdmCollection]
  # @return [Array<GenericObject>]
  def query_member_objects(collection:)
    Hyrax.query_service.find_inverse_references_by(resource: collection,
      property: "member_of_collection_ids",
      model: ::GenericObject)
  end
end
