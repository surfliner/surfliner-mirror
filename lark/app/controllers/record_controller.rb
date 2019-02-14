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
    record = adapter.query_service.find_by(id: params['id'])
    json   = { id: record.id.to_s, pref_label: record.pref_label.first }.to_json

    [200, {}, [json]]
  rescue Valkyrie::Persistence::ObjectNotFoundError => err
    [404, {}, [err.message]]
  end

  private

  def adapter
    Valkyrie::MetadataAdapter.find(Lark.config.index_adapter)
  end
end
