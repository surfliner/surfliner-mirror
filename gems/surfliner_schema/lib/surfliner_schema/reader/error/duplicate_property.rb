# frozen_string_literal: true

module SurflinerSchema
  class Reader
    module Error
      ##
      # A schema defined the same property with the same availability twice.
      class DuplicateProperty < StandardError
      end
    end
  end
end
