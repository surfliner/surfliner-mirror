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
      mapping = mappings["http://purl.org/dc/elements/1.1/#{term}"].to_a
      # At present, `:title` is provided by Hyrax, not the schema.
      mapping += resource.title.to_a if term === :title
      # OAI doesn’t support datatyping so everything should be cast to a string.
      json[term] = mapping.map(&:to_s) if mapping.size > 0
    end
    {
      "@context" => {
        "@vocab" => "http://purl.org/dc/elements/1.1/",
        "ore" => "http://www.openarchives.org/ore/terms/"
      },
      "@id" => iri,
      **mapped
    }
  end
end
