# frozen_string_literal: true

class DiscoveryPlatformService
  class << self
    # Build the label and URL for the discovery links from discover_groups. Assuring that:
    # The label for a platform  can be retrieve by I18n localization with key in pattern `discovery_platform.#{platform_name)}.label`
    # The URL base is configured with an environment key in pattern `DISCOVER_PLATFORM_#{platform_name.upcase}_URL_BASE`.
    #
    # @example By default, the syntax of the link url for a discovery platform will be
    #   `ENV['DISCOVER_PLATFORM_#{platform_name.upcase}_URL_BASE']/#{object_id}`,
    #   If a platform have a base url `http://localhost:3000/myplatform`, the url will looks like the following:
    #   http://localhost:3000/myplatform/my_id
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

          case platform_name.to_sym
          when :tidewater
            resource_url = DiscoveryPlatformPublisher.api_uri_for(resource)
            pro << [I18n.t(label_i18n_key), "#{url_base}#{ERB::Util.url_encode(resource_url)}"]
          else
            pro << [I18n.t(label_i18n_key), "#{url_base}/#{object}"]
          end
        end
      end
    end
  end
end
