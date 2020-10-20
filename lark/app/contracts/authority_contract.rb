# frozen_string_literal: true

##
# @see https://dry-rb.org/gems/dry-validation/
class AuthorityContract < Dry::Validation::Contract
  params do
    required(:pref_label).filled(:string)
  end
end
