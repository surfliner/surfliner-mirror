#!/bin/sh
set -e

# source env vars from vault secret file
if [ "$VAULT_FILE" ] && [ -e "$VAULT_FILE" ]; then
  # shellcheck source=/dev/null
  . "$VAULT_FILE"
fi

exec "$@"
