##
# This is Comet's preferred presenter for displaying {GenericObject}
class CometObjectPresenter < Hyrax::WorkShowPresenter
  # Delegate schema fields to the model.
  delegate(*::SchemaLoader.new.properties_for(:generic_object).keys, to: :model)

  ##
  # @return [String] the ARK for the object, if assigned
  def ark
    model.ark
  end

  ##
  # Provides a data structure representing the discovery links for this object.
  #
  # When the object is published in a given discovery platform, we want to
  # display that in a way that makes it possible for users to review the status
  # of those links.
  #
  # @return [[]]
  def discovery_links
    DiscoveryPlatformService.call(solr_document[:id])
  end
end
