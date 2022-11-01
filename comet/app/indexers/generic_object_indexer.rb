# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource GenericObject`
class GenericObjectIndexer < Hyrax::ValkyrieWorkIndexer
  include Hyrax::Indexer(:basic_metadata)
  include Hyrax::Indexer(:generic_object, index_loader: ::SchemaLoader.new)

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
end
