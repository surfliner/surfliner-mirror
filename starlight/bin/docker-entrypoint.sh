#!/bin/sh
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /home/starlight/app/tmp/pids/server.pid

# source env vars from vault secret file
if [ "$VAULT_FILE" ] && [ -e "$VAULT_FILE" ]; then
  # shellcheck source=/dev/null
  . "$VAULT_FILE"
fi

# Then exec the container's main process
# This is what's set as CMD in a) Dockerfile b) compose c) CI
exec "$@"
