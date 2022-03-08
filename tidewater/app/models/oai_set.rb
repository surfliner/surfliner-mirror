# frozen_string_literal: true

# For more details, see http://www.openarchives.org/OAI/openarchivesprotocol.html#Set
class OaiSet < ApplicationRecord
  def spec
    id.to_s
  end
end
