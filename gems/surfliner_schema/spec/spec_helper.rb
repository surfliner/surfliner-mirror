# frozen_string_literal: true

RSpec.configure do |config|
  config.order = :random
  Kernel.srand config.seed
end
