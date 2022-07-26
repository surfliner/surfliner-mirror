##
# A read-only AccessControlList
class AccessControlList < Hyrax::Acl::AccessControlList
  def initialize(resource:, query_service: Superskunk.comet_query_service, persister: nil)
    raise(ArgumentError, "don't try to persist me!") unless persister.nil?
    super(resource: resource, query_service: query_service, persister: nil)
  end
end
