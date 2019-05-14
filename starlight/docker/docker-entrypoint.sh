#!/bin/sh
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /home/starlight/app/tmp/pids/server.pid

bundle exec rake db:create db:schema:load

# Then exec the container's main process
# This is what's set as CMD in a) Dockerfile b) compose c) CI
exec "$@"
