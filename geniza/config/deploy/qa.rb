# frozen_string_literal: true
server 'geniza-qa.curationexperts.com', user: 'deploy', roles: [:web, :app, :db]
set :deploy_to, ENV.fetch('TARGET', '/opt/geniza')
set :rails_env, 'production'
append :linked_files, "config/database.yml"
append :linked_files, "config/blacklight.yml"
append :linked_files, "config/environments/production.rb"
append :linked_files, ".env.production"
set :assets_prefix, "#{shared_path}/public/assets"
