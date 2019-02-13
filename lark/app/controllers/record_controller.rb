##
# A simple controller that resolves requests for authority records.
class RecordController
  attr_accessor :params

  def initialize(params)
    self.params = params
  end

  def call
    return [404, {}, ['']] unless params['id'] == 'a_real_id'

    [200, {}, [JSON.dump(id: params['id'], prefLabel: 'Moomin')]]
  end
end
