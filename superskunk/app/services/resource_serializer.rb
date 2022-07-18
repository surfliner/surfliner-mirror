##
# A resource serializer.
#
# Subclasses should implement a #to_jsonld method and be added alongside the
# appropriate profile in ResourceSerializer.supported_profiles.
class ResourceSerializer
  ##
  # Use ResourceSerializer.serialize instead.
  def initialize(resource:, profile:)
    @resource = resource
    @profile = profile
  end

  ##
  # The resource to serialize.
  attr_reader :resource

  ##
  # The profile to use when serializing.
  attr_reader :profile

  ##
  # The IRI for the resource.
  def iri
    "#{ENV["SUPERSKUNK_API_BASE"]}/resources/#{resource.id}"
  end

  ##
  # Mappings of the resource which have been defined for the current profile.
  def mappings
    @mappings ||= resource.mapped_to(profile)
  end

  ##
  # Raised when attempting to serialize an unsupported profile.
  class UnsupportedProfileError < StandardError
  end

  ##
  # Serializes the provided resource according to the provided profile.
  def self.serialize(resource:, profile:)
    serializer = supported_profiles[profile]
    raise UnsupportedProfileError("The profile #{profile} is not supported.") unless serializer
    serializer.new(resource: resource, profile: profile).to_jsonld
  end

  ##
  # A hash associating profile strings with the resource serializer used to
  # serialize them.
  def self.supported_profiles
    {"tag:surfliner.gitlab.io,2022:api/oai_dc" => OaiDcSerializer}
  end
end
