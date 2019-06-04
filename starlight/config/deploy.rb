# frozen_string_literal: true

SSHKit.config.command_map[:rake] = "bundle exec rake"

set :application, "starlight"

set :repo_url, "https://gitlab.com/surfliner/surfliner.git"
set :repo_tree, "starlight"

set :deploy_to, ENV.fetch("CAP_TARGET", "/opt/starlight")

set :rbenv_type, :system

set :log_level, :debug
set :bundle_flags, "--without=development test"
set :bundle_env_variables, nokogiri_use_system_libraries: 1

set :keep_releases, 2
set :passenger_restart_with_touch, true
set :assets_prefix, "#{shared_path}/public/assets"

set :linked_dirs, %w[
  tmp/pids
  tmp/cache
  tmp/sockets
  public/assets
  public/uploads
  public/sitemaps
]

# Default branch is :master
set :branch, ENV["CAP_REVISION"] || "master"

after "deploy:restart", "sidekiq:restart"
