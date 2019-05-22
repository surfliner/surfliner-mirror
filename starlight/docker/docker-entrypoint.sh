#!/bin/sh
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /home/starlight/app/tmp/pids/server.pid

# Extract DB host and port
if [ -z ${DATABASE_URL+x} ]; then
  echo "DATABASE_URL is not supplied, skipping database setup";
else
  db_host=$(echo "$DATABASE_URL" | cut -d "@" -f2 | cut -d "/" -f1 | cut -d ":" -f1)
  db_port=$(echo "$DATABASE_URL" | cut -d "@" -f2 | cut -d "/" -f1 | cut -d ":" -f2)
  # if port wasn't specified, use default PG port
  if [ "$db_port" = "$db_host" ]; then
    db_port=5432
  fi

  while ! nc -z "$db_host" "$db_port"
  do
    echo "waiting for postgresql"
    sleep 1
  done

  bundle exec rake db:create db:schema:load
fi

# Then exec the container's main process
# This is what's set as CMD in a) Dockerfile b) compose c) CI
exec "$@"
