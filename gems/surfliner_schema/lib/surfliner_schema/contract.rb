module SurflinerSchema
  class Contract < Dry::Validation::Contract
    config.messages.default_locale = :en
  end
end
