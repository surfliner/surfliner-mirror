# frozen_string_literal: true

require 'factory_bot'
require 'fakes/fake_listener'

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.profile_examples = 10
  config.order            = :random

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  # Use the documentation formatter for detailed output,
  # unless a formatter has already been configured
  # (e.g. via a command-line flag).
  config.default_formatter = 'doc' if config.files_to_run.one?

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  Kernel.srand config.seed
end
