# frozen_string_literal: true

module SurflinerSchema
  class Reader
    module Error
      ##
      # The range of a property was not recognized.
      class UnknownRange < ArgumentError
      end
    end
  end
end
