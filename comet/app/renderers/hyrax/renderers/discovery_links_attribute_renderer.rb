module Hyrax
  module Renderers
    # Used by PresentsAttributes to show discovery links:
    # presenter.attribute_to_html(:discovery_links, render_as: :discovery_links)
    class DiscoveryLinksAttributeRenderer < AttributeRenderer
      private

      ##
      # link to the discover platform
      def attribute_value_to_html(value)
        val = JSON.parse(value)

        return link_to(ERB::Util.h(val[0]), val[1]) if val.is_a?(Array) && val.length == 2
        link_to(ERB::Util.h(val), val)
      end
    end
  end
end
