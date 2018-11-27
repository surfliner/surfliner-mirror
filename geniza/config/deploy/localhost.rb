# frozen_string_literal: true
server '127.0.0.1', user: 'deploy', roles: [:web, :app, :db]
set :deploy_to, ENV.fetch('TARGET', '/opt/geniza')
