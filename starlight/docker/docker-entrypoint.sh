#!/bin/sh
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

gem update bundler
bundle check || bundle install --jobs "$(nproc)"
yarn install

bundle exec rake db:create db:schema:load

# Then exec the container's main process (what's set as CMD in the Dockerfile).
# This isn't relevant at the moment
exec "$@"
