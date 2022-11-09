# frozen_string_literal: true

module Indexers
  ##
  # Dynamically creates a new +ResourceIndexer+ class for the provided
  # (+Resource+) model class.
  def self.ResourceIndexer(model_class)
    Class.new(Hyrax::ValkyrieWorkIndexer) do
      @model_class = model_class

      prepend ::Indexers::ResourceIndexer

      include Hyrax::Indexer(:basic_metadata)
      include Hyrax::Indexer(model_class.resource_class.name, index_loader: ::SchemaLoader.new)

      def self.inspect
        return "ResourceIndexer(#{@model_class})" if name.blank?
        super
      end
    end
  end

  ##
  # This is defined as a module and prepended because its +to_solr+ method needs
  # to override those defined in the more specific indexer classes.
  module ResourceIndexer
    def to_solr
      super.transform_values do |value|
        cast_literals(value)
      end.merge(
        rendering_ids_ssim: resource.rendering_ids.map(&:to_s)
      )
    end

    def cast_literals(value)
      case value
      when Enumerable
        value.map { |v| cast_literals(v) }
      when RDF::Literal
        value.plain? ? value.value : value.object
      else
        value
      end
    end

    ##
    # Dynamically returns a new ResourceIndexer subclass for the provided
    # Resource.
    def self.for(resource:)
      ::Indexers::ResourceIndexer(resource.class).new(resource: resource)
    end
  end
end