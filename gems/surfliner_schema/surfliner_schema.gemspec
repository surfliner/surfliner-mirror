# frozen_string_literal: true

require_relative "lib/surfliner_schema/version"

Gem::Specification.new do |spec|
  spec.name = "surfliner_schema"
  spec.version = SurflinerSchema::VERSION
  spec.authors = ["Project Surfliner"]

  spec.homepage = "https://gitlab.com/surfliner/surfliner"
  spec.license = "MIT"
  spec.summary = "Surfliner/Valkyrie schema processing"

  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://gitlab.com/surfliner/surfliner.git"

  spec.files = Dir["lib/**/*.rb"] + Dir["bin/*"] + Dir["[A-Z]*"]

  spec.add_dependency "activesupport"
  spec.add_dependency "iso-639", ">= 0.3.0", "< 0.4.0"
  spec.add_dependency "valkyrie", ">= 2.2", "< 4"

  spec.add_development_dependency "debug", "~> 1.4.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "standard", "~> 1.7.0"
end
