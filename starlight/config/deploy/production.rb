# frozen_string_literal: true

set :stage, :production
set :rails_env, 'production'

server ENV.fetch('SERVER'), user: ENV.fetch('CAP_USER'), roles: [:web, :app, :db]
set :ssh_options, port: 22, keys: [ENV.fetch('KEYFILE')]

after "deploy:restart", "sitemap:refresh" if ENV["SITEMAP_REFRESH"].present?
