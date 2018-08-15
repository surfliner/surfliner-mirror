# frozen_string_literal: true

set :application, 'spotlight'

set :repo_url, 'https://github.com/ucsblibrary/geniza.git'
set :deploy_to, ENV.fetch('TARGET', '/opt/spotlight')

set :stages, %w[production]

set :log_level, :debug
set :bundle_flags, '--without=development test'
set :bundle_env_variables, nokogiri_use_system_libraries: 1

set :keep_releases, 2
set :passenger_restart_with_touch, true
set :assets_prefix, "#{shared_path}/public/assets"

set :linked_dirs, %w[
  tmp/pids
  tmp/cache
  tmp/sockets
  public/assets
]

# Default branch is :master
set :branch, ENV['REVISION'] || ENV['BRANCH_NAME'] || 'master'

set :linked_files, %w[
  config/secrets.yml
  config/import.yml
]

SSHKit.config.command_map[:rake] = 'bundle exec rake'
