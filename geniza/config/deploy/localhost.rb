# frozen_string_literal: true
server '127.0.0.1', user: 'deploy', roles: [:web, :app, :db]
set :deploy_to, ENV.fetch('TARGET', '/opt/geniza')
set :rails_env, 'production'
append :linked_files, "config/database.yml"
set :assets_prefix, "#{shared_path}/public/assets"
append :linked_files, ".env.production"
