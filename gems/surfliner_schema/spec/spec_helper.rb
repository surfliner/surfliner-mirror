# frozen_string_literal: true

require "surfliner_schema"

RSpec.configure do |config|
  config.order = :random
  Kernel.srand config.seed
end
