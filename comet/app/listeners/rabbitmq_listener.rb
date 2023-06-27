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
  #
  # @!attribute [rw] publisher_class
  #   @return [.open_on]  a class yielding a {DiscoveryPlatformPublisher} from
  #     +.open_on+
  #   @see DiscoveryPlatformPublisher for the reference implementation
  attr_accessor :platform_name, :publisher_class

  ##
  # @param platform_name [Symbol]
  # @param publisher_class [.open_on] a class yielding a
  #   {DiscoveryPlatformPublisher} from +.open_on+
  def initialize(platform_name:, publisher_class: DiscoveryPlatformPublisher)
    self.platform_name = platform_name
    self.publisher_class = publisher_class
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
    Hyrax.logger.debug { "Received collection.publish event for collection with id #{event[:collection].id}, targeting platform: #{platform_name}" }
    collection = event[:collection]

    publisher_class.open_on(platform_name) do |publisher|
      publisher.append_access_control_to(resource: collection)

      query_member_objects(collection: collection).each do |obj|
        publisher.publish(resource: obj)
      rescue DiscoveryPlatformPublisher::UnpublishableObject => err
        # log and continue publishing the remainder of the collection
        Hyrax.logger.error { "Failed to publish #{obj.class} with id #{obj.id} from collection #{collection.id} to platform: #{platform_name}." }
        Hyrax.logger.error(err.message)
      end
    end
  rescue => err
    Hyrax.logger.error(err)
  end

  ##
  # Updates the object in the platform when metadata is updated.
  def on_object_metadata_updated(event)
    Hyrax.logger.debug { "Received object.metadata.updated event for #{event[:object].class} with id #{event[:object].id} targeting platform: #{platform_name}" }

    publisher_class.open_on(platform_name) do |publisher|
      publisher.update(resource: event[:object])
    end
  rescue => err
    Hyrax.logger.error(err)
  end

  ##
  # Handles unpublishing when the object has been destroyed
  #
  # @param event [{:object => GenericObject}]
  def on_object_deleted(event)
    Hyrax.logger.debug("Received object.deleted event for #{event[:object].class} with id #{event[:object].id} targeting platform: #{platform_name}")

    object = event[:object]
    object.state = Vocab::FedoraResourceStatus.deleted

    publisher_class.open_on(platform_name) do |publisher|
      publisher.unpublish(resource: object)
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
    Hyrax.logger.debug("Received object.unpublish event for #{event[:object].class} with id #{event[:object].id} targeting platform: #{platform_name}")

    publisher_class.open_on(platform_name) do |publisher|
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
      property: "member_of_collection_ids")
  end
end
