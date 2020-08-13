require_relative 'lib/solrconf/version'

Gem::Specification.new do |spec|
  spec.name          = "solrconf"
  spec.version       = Solrconf::VERSION
  spec.authors       = ["Alexandra Dunn"]
  spec.email         = ["dunn.alex@gmail.com"]

  spec.homepage      = "https://gitlab.com/surfliner/surfliner"
  spec.license       = "MIT"
  spec.summary       = %q{Solr configuration tasks.}

  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://gitlab.com/surfliner/surfliner.git"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rake"
  spec.add_dependency "rsolr"
  spec.add_dependency "zk"
end
