# frozen_string_literal: true

module IndexerForOverride
  ##
  # Override the default +Hyrax::ValkyrieIndexer.for+ method to return a
  # +ResourceIndexer+ when the provided value is a +Resource+.
  def for(resource:)
    case resource
    when ::Resource
      indexer_class = "#{resource.class}Indexer".safe_constantize
      if indexer_class.is_a?(Class) && indexer_class.instance_methods.include?(:to_solr)
        indexer_class
      else
        ::Indexers::ResourceIndexer.for(resource: resource)
      end
    else
      super(resource: resource)
    end
  end
end

Hyrax::ValkyrieIndexer.singleton_class.class_eval do
  prepend IndexerForOverride
end
