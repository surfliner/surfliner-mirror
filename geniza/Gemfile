# frozen_string_literal: true

source 'https://rubygems.org'

group :production do
  gem 'pg', '~> 0.18.4'
end

gem 'blacklight', ' ~> 6.0'
gem 'blacklight-gallery', '>= 0.3.0'
gem 'blacklight-oembed', '>= 0.1.0'
gem 'blacklight-spotlight',
    git: 'https://github.com/dunn/spotlight.git',
    branch: '75th'
gem 'devise'
gem 'devise-guests', '~> 0.6'
gem 'devise_invitable'
gem 'friendly_id'
gem 'jquery-rails'
gem 'net-ldap'
gem 'optimist'
gem 'puma'
gem 'rails', '~> 5.1.6'
gem 'riiif'
gem 'rsolr', '>= 1.0'
gem 'sass-rails'
gem 'sitemap_generator'
gem 'uglifier', '>= 1.3.0'

group :development, :test do
  gem 'capistrano', '~> 3.8.0'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
  gem 'capistrano-rails', '>= 1.1.3'
  gem 'highline'

  gem 'byebug'
  gem 'capybara'
  gem 'sqlite3'
  gem 'method_source'
  gem 'pry'
  gem 'pry-doc'
  gem 'selenium-webdriver'
  gem 'solr_wrapper', '>= 0.3'
end
