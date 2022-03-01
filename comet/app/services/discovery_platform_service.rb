# frozen_string_literal: true

class DiscoveryPlatformService
  class << self
    # Build the label and URL for the discovery links from discover_groups. Assuring that:
    # The label for a platform  can be retrieve by I18n localization with key in pattern `discovery_platform.#{platform_name)}.label`
    # The URL base is configured with an environment key in pattern `DISCOVER_PLATFORM_#{platform_name.upcase}_URL_BASE`.
    #
    # By default, the syntax of the URL for a discovery platform will be formed by the base url and the resource URL sent to RabbitMQ as source_iri:
    #   `ENV['DISCOVER_PLATFORM_#{platform_name.upcase}_URL_BASE']#{source_iri}`,
    # A tipical link path will be something like:
    #   `/platform_name/item?source_iri=https://the.url/sent/to/rabbitmq`
    #
    # @example tidewater platform tracks records by source_iri with a path like
    #   `http://localhost:3000/tidewater/item?source_iri=https://the.url/sent/to/rabbitmq`,
    #   and the following environment variable need to setup for the base url:
    #    `DISCOVER_PLATFORM_TIDEWATER_URL_BASE=http://localhost:3000/tidewater/item?source_iri=`
    #
    # @param [#id] object - the object id to get the discovery platforms for
    # @return [Array<String, String>] - list of label and URL of the discovery platforms
    def call(object)
      resource = Hyrax.query_service.find_by(id: object)

      [].tap do |pro|
        Hyrax::PermissionManager.new(resource: resource).discover_groups.each do |group|
          platform_name = group.gsub("surfliner:", "")
          label_i18n_key = "discovery_platform.#{platform_name}.label"
          url_base = ENV.fetch("DISCOVER_PLATFORM_#{platform_name.upcase}_URL_BASE") { Rails.application.config.metadata_api_uri_base }

          resource_url = DiscoveryPlatformPublisher.api_uri_for(resource)
          pro << [I18n.t(label_i18n_key), "#{url_base}#{ERB::Util.url_encode(resource_url)}"]
        end
      end
    end
  end
end
