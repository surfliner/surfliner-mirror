# frozen_string_literal: true

set :stage, :production
set :rails_env, 'production'

server ENV['SERVER'], user: ENV['CAP_USER'], roles: [:web, :app, :db]
set :ssh_options, port: 22, keys: [ENV.fetch('KEYFILE', '~/.ssh/id_rsa')]

after "deploy:restart", "sitemap:refresh"
