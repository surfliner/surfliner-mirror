# frozen_string_literal: true

set :stage, :staging
set :rails_env, 'staging'

server ENV['SERVER'], user: ENV['CAP_USER'], roles: [:web, :app, :db]
set :ssh_options, port: 22, keys: [ENV.fetch('KEYFILE', '~/.ssh/id_rsa')]
