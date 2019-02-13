##
# A simple controller that resolves requests for authority records.
class RecordController
  attr_accessor :params

  def initialize(params)
    self.params = params
  end

  ##
  # https://dry-rb.org/gems/dry-view/
  def call
    resource = adapter.query_service.find_by(id: params['id'])

    [200, {}, [resource.to_json]]
  rescue Valkyrie::Persistence::ObjectNotFoundError => err
    [404, {}, [err.message]]
  end

  private

  def adapter
    Valkyrie::MetadataAdapter.find(Lark.config.index_adapter)
  end
end
