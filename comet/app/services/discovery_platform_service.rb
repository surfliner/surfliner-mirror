# frozen_string_literal: true

class DiscoveryPlatformService
  class << self
    # Build the label and URL for the discovery links from discover_groups.
    #
    # The label for a platform can be retrieved via I18n localization using the
    # key `"discovery_platform.#{platform_name)}.label"`.
    #
    # The URL base is configured with an environment variable of the form
    # `"DISCOVER_PLATFORM_#{platform_name.upcase}_URL_BASE"`.
    #
    # By default, the syntax of the URL for a discovery platform passes through
    # the resource URL sent to RabbitMQ as a `source_iri` query parameter. A
    # typical link will look something like
    # `http://example.com/item?source_iri=https://the.url/sent/to/rabbitmq`.
    #
    # @param [#id] object - the object id to get the discovery platforms for
    # @return [Array<String, String>] - list of label and URL of the discovery platforms
    def call(object)
      resource = Hyrax.query_service.find_by(id: object)

      [].tap do |pro|
        Hyrax::PermissionManager.new(resource: resource).discover_groups.each do |group|
          next unless group.start_with?(DiscoveryPlatform.group_name_prefix)
          platform_name = group.delete_prefix(DiscoveryPlatform.group_name_prefix)
          label_i18n_key = "discovery_platform.#{platform_name}.label"
          url_base = ENV.fetch("DISCOVER_PLATFORM_#{platform_name.upcase}_URL_BASE") { Rails.application.config.metadata_api_uri_base }

          resource_url = DiscoveryPlatformPublisher.api_uri_for(resource)
          pro << [I18n.t(label_i18n_key), "#{url_base}#{ERB::Util.url_encode(resource_url)}"]
        end
      end
    end
  end
end
