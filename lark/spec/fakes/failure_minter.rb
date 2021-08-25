# frozen_string_literal: true

##
# a very sad minter that always fails
class FailureMinter
  def mint
    raise Lark::Minter::MinterError, "i always fail :("
  end
end
