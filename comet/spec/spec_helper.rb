RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "tmp/examples.txt"
  config.disable_monkey_patching!

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |c|
    c.max_formatted_output_length = nil
  end
end
