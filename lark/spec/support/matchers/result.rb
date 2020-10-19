# frozen_string_literal: true

##
# Custom RSpec matchers for result monads.
#
# @see https://dry-rb.org/gems/dry-monads/1.3/result/
#
# Note that builtin RSpec matchers go a long way toward supporting
# `Dry::Monads[:result]`; for example: `be_success` and `be_failure` are very
# useful when advanced matching isn't necessary.
#
# @example usage for Failure
#
#   expect(transaction.call(*args)).not_to be_success
#   expect(transaction.call(*args)).to be_failure
#
#   expect(transaction.call(*args))
#     .to be_a_transaction_failure
#     .with_reason(:some_reason)
#
#   expect(transaction.call(*args))
#     .to be_a_transaction_failure
#     .with_reason(:another_reason)
#     .and_message('this is the message passed with the failure')
#
RSpec::Matchers.define :be_a_transaction_failure do |expected|
  match do |actual|
    actual.failure? &&
      (@reason.nil? || actual.failure[:reason] == @reason) &&
      (@message.nil? || actual.failure[:message] == @message)
  end

  ##
  # match `result.failure[:reason]` data
  chain :with_reason do |reason|
    @reason = reason
  end

  ##
  # match `result.failure[:message]` data
  chain :and_message do |message|
    @message = message
  end
end
