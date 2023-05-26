# frozen_string_literal: true

module Hyrax
  module Workflow
    ##
    # Publishes an object to the Shoreline discovery platform
    module PublishObjectToShoreline
      def self.call(target:, **)
        Hyrax.logger.info("PublishObject.call with #{target.id}.")
        model = target.try(:model) || target # get the model if target is a ChangeSet
        DiscoveryPlatformPublisher.open_on(:shoreline) do |pub|
          Hyrax.logger.debug("Publishing #{target.id} to shoreline")
          pub.publish(resource: model)
        end
      rescue => err
        Hyrax.logger.error(err)
      end
    end
  end
end
