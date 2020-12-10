# frozen_string_literal: true

class FakeLarkClient
  def get(id)
    { pref_label: 'Comet in Moominland', id: id }
  end
end
