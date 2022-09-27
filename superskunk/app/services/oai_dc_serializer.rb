##
# A resource serializer for OAI/DC.
class OaiDcSerializer < ResourceSerializer
  ##
  # Returns a hash representing the JSON-LD which represents the resource as
  # OAI/DC.
  def to_jsonld
    mapped = [
      :contributor, :coverage, :creator, :date, :description, :format,
      :identifier, :language, :publisher, :relation, :rights, :source, :subject,
      :title, :type
    ].each_with_object({}) do |term, json|
      propertity_iri = "http://purl.org/dc/elements/1.1/#{term}"
      mapping = mappings.values
        .select { |mapping| mapping[:property_iri] == propertity_iri }
        .map { |prop| prop[:value].to_a }.flatten
      # At present, `:title` is provided by Hyrax, not the schema.
      mapping += resource.title.to_a if term === :title
      # OAI doesn’t support datatyping so everything should be cast to a string.
      json[term] = mapping.map(&:to_s) if mapping.size > 0
    end
    collections = Collection.all_discoverable_parents(
      resource: resource,
      agent: agent
    )
    {
      "@context" => {
        "@vocab" => "http://purl.org/dc/elements/1.1/",
        "ore" => "http://www.openarchives.org/ore/terms/"
      },
      "@id" => iri,
      **mapped,
      "ore:isAggregatedBy" => collections.map { |collection|
        {
          "@id" => "#{ENV["SUPERSKUNK_API_BASE"]}/resources/#{collection.id}",
          "title" => collection.title.first || ""
        }
      }
    }
  end
end
