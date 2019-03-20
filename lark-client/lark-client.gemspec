#!/usr/bin/env ruby -rubygems
# frozen_string_literal: true

Gem::Specification.new do |gem|
  gem.version               = File.read('VERSION').chomp
  gem.date                  = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name                  = 'lark-client'
  gem.homepage              = 'http://gitlab.com/surfliner/surfliner'
  gem.license               = 'MIT'
  gem.authors               = ['tom johnson']
  gem.email                 = 'tomjohnson@ucsb.edu'
  gem.summary               = 'A simple client for the Lark authority server.'

  gem.platform              = Gem::Platform::RUBY
  gem.files                 = %w[README.md LICENSE VERSION] +
                              Dir.glob('lib/**/*.rb')
  gem.require_paths         = %w[lib]

  gem.required_ruby_version = '>= 2.5.0'
  gem.requirements          = []

  gem.add_development_dependency 'rake',          '~> 12.0'
  gem.add_development_dependency 'rspec',         '~> 3.7'
  gem.add_development_dependency 'rubocop',       '0.66.0'
  gem.add_development_dependency 'rubocop-rspec', '~> 1.32'
  gem.add_development_dependency 'yard',          '~> 0.9.12'

  gem.post_install_message = nil
end
