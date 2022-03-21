# frozen_string_literal: true

require_relative 'lib/solr_utils/version'

Gem::Specification.new do |spec|
  spec.name          = 'solr_utils'
  spec.version       = SolrUtils::VERSION
  spec.authors       = ['Alexandra Dunn']
  spec.email         = ['dunn.alex@gmail.com']

  spec.homepage      = 'https://gitlab.com/surfliner/surfliner'
  spec.license       = 'MIT'
  spec.summary       = 'Solr configuration tasks.'

  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://gitlab.com/surfliner/surfliner.git'

  spec.files = Dir['lib/**/*.rb'] + Dir['lib/**/*.rake'] + Dir['bin/*'] + Dir['[A-Z]*']

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rake'
  spec.add_dependency 'rsolr'
  spec.add_dependency 'zk', '~> 1.10.0'
  spec.add_dependency 'zookeeper', '~> 1.5.1'
end
