# frozen_string_literal: true

module SurflinerSchema
  class Reader
    module Error
      ##
      # No configuration file exists for a requested schema.
      class UndefinedSchema < ArgumentError
      end
    end
  end
end
