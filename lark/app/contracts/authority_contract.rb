class AuthorityContract < Dry::Validation::Contract
  params do
    required(:pref_label).filled(:string)
  end
end
