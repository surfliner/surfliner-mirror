module Presenters
  def self.CometObjectPresenter(model_class:)
    Class.new(::Presenters::CometObjectPresenter) do
      @model_class = model_class

      delegate(*::SchemaLoader.new.properties_for(model_class.availability).keys, to: :model)

      class << self
        attr_reader :model_class
      end
    end
  end

  class CometObjectPresenter < Hyrax::WorkShowPresenter
    # Delegate arks to the model.
    delegate :ark, to: :model

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

    ##
    # Provides an array of property names defined on the model in the schema.
    #
    # @return [Array<Symbol>]
    def schema_property_names
      ::SchemaLoader.new.properties_for(model.class.availability).values
    end

    ##
    # Returns a new class derived from +Presenters::CometObjectPresenter+
    # suitable for presenting the provided model.
    def self.class_for(model:)
      ::Presenters::CometObjectPresenter(model_class: model.class)
    end
  end
end
