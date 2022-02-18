# frozen_string_literal: true

class DiscoveryPlatformService
  class << self
    # Build the label and URL for the discovery links from discover_groups. Assuring that:
    # The label for a platform  can be retrieve by I18n localization with key in pattern `discovery_platform.#{platform_name)}.label`
    # The URL base is configured with an environment key in pattern `DISCOVER_PLATFORM_#{platform_name.upcase}_URL_BASE`
    #
    # @param [#id] object - the object id to get the discovery platforms for
    # @return [[String, String]] - list of label and URL of the discovery platforms
    def call(object)
      resource = Hyrax.query_service.find_by(id: object)

      [].tap do |pro|
        Hyrax::PermissionManager.new(resource: resource).discover_groups.each do |group|
          platform_name = group.gsub("surfliner:", "")
          label_i18n_key = "discovery_platform.#{platform_name}.label"
          url_base = ENV.fetch("DISCOVER_PLATFORM_#{platform_name.upcase}_URL_BASE") { Rails.application.config.metadata_api_uri_base }

          pro << [I18n.t(label_i18n_key), "#{url_base}/#{object}"]
        end
      end
    end
  end
end
