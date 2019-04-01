# frozen_string_literal: true

set :stage, :production
set :rails_env, "production"

set :default_env,
    "http_proxy" => ENV["CAP_PROXY"],
    "https_proxy" => ENV["CAP_PROXY"]

server ENV.fetch("CAP_SERVER"), user: ENV.fetch("CAP_USER"), roles: [:web, :app, :db]
set :ssh_options, port: 22, keys: [ENV.fetch("CAP_KEYFILE") { "~/.ssh/id_rsa" }]

after "deploy:restart", "sitemap:refresh" if ENV["CAP_SITEMAP_REFRESH"]
