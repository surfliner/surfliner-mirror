# frozen_string_literal: true

set :stage, :production
set :rails_env, 'production'

# Uncomment if deploying to a server without a public IP
# set :default_env,
#     'http_proxy' => 'http://10.3.100.201:3128',
#     'https_proxy' => 'http://10.3.100.201:3128'

server ENV['SERVER'], user: ENV['CAP_USER'], roles: [:web, :app, :db]
set :ssh_options, port: 22, keys: [ENV.fetch('KEYFILE', '~/.ssh/id_rsa')]

after "deploy:restart", "sitemap:refresh"
