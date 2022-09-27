##
# A resource serializer for ShorelineIngest.
class ShorelineIngestSerializer < ResourceSerializer
  ##
  # Returns a hash representing the JSON-LD which represents the resource as
  # ShorelineIngest.
  def to_jsonld
    {}.tap do |prod|
      prod["@id"] = iri
      prod[:title] = resource.title.to_a
    end.merge build_jsonld(mappings)
  end

  private

  ##
  # build jsonld with mappings
  # @param mappings [Hash<String, Hash<String, String[]>>]
  def build_jsonld(mappings)
    {}.tap do |json|
      json["@context"] ||= {}

      mappings.keys.each do |name|
        next unless mappings[name][:value].size > 0

        json["@context"][name] = mappings[name][:property_iri]
        json[name] = mappings[name][:value].map(&:to_s)
      end
    end
  end
end
