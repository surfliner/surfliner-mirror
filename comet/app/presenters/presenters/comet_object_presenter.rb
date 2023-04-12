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
    # Count for file sets
    # @return [Integer]
    def file_sets_count
      @file_sets_count ||= file_set_presenters.count
    end

    ##
    # Count for components
    # @return [Integer]
    def components_count
      @components_count ||= work_presenters.count
    end

    # @return [Integer] total number of pages of viewable items
    def total_pages
      (authorized_item_ids.size.to_f / rows_from_params.to_f).ceil
    end

    def authorized_item_ids(filter_unreadable: Flipflop.hide_private_items?)
      super

      tab = request.params[:tab]
      ((tab == "components") ? (@member_item_list_ids - file_set_ids) : (@member_item_list_ids & file_set_ids))
    end

    # @return [Array] list of file set ids in the object
    def file_set_ids
      file_set_presenters.map { |fp| fp.id }
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
