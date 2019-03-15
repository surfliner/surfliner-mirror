#!/bin/bash
set -e

cd /app || exit

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

gem update bundler
bundle install --jobs "$(nproc)" --path=vendor/bundle
yarn install
bundle exec rake db:create db:schema:load

if [ "$RAILS_ENV" = "test" ]; then
  bundle exec puma -b tcp://0.0.0.0:3001
else
  bundle exec puma
fi

# Then exec the container's main process (what's set as CMD in the Dockerfile).
# This isn't relevant at the moment
# exec "$@"
