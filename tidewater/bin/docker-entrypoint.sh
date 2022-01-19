#!/bin/sh
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /home/tidewater/app/tmp/pids/server.pid

# Then exec the container's main process
# This is what's set as CMD in a) Dockerfile b) compose c) CI
exec "$@"
