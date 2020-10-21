# frozen_string_literal: true

##
# Custom RSpec matchers for `dry-validation` contracts.
#
# @see https://dry-rb.org/gems/dry-validation/
#
# @example checking that particular attributes have validation errors
#
#   expect(MyContract.new.call(data_to_validate))
#     .to have_validation_errors_on(:attrs, :that, :should, :error)
#
RSpec::Matchers.define :have_validation_errors_on do |expected|
  match do |actual|
    actual.failure? &&
      Array(expected).all? { |attr| !actual.errors[attr].nil? }
  end
end
