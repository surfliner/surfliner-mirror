# frozen_string_literal: true

module SurflinerSchema
  class Reader
    module Error
      ##
      # The format of a schema was not recognized.
      class NotRecognized < ArgumentError
      end
    end
  end
end
