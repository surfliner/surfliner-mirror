# frozen_string_literal: true

class DiscoveryPlatformService
  class << self
    # @param [#id] object - the object id to get the discovery platforms for
    # @return [[String, String]] - list of label and URL of the discovery platforms
    def call(object)
      resource = Hyrax.query_service.find_by(id: object)

      [].tap do |pro|
        Hyrax::PermissionManager.new(resource: resource).discover_groups.each do |group|
          pro << case group
          when "surfliner:tidewater"
            [I18n.t("discovery_platform.tidewater.label"), "#{Rails.application.config.tidewater_uri_base}/#{object}"]
          else
            ["Unhandled discover platform #{group}", "#{Rails.application.config.metadata_api_uri_base}/#{object}"]
          end
        end
      end
    end
  end
end
