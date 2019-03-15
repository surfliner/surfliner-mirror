# frozen_string_literal: true

CONFIG = YAML.safe_load(
  ERB.new(File.read(Rails.root.join("config", "import.yml"))).result
).with_indifferent_access.freeze
