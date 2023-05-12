# frozen_string_literal: true

module ExporterOverride
  # @Override use schema properties
  def export_properties
    Bulkrax.curation_concerns.map { |work| Bulkrax::ValkyrieObjectFactory.schema_properties(work) }.flatten.uniq.sort
  end
end

Bulkrax::Exporter.class_eval do
  prepend ExporterOverride
end
