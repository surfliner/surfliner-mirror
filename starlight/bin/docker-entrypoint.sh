#!/bin/sh
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /home/starlight/app/tmp/pids/server.pid

# Get DB host and port
if [ -z "${DATABASE_URL}" ]; then
  db_host=${POSTGRES_HOST}
  db_port=${POSTGRES_PORT}
else
  db_host=$(echo "$DATABASE_URL" | cut -d "@" -f2 | cut -d "/" -f1 | cut -d ":" -f1)
  db_port=$(echo "$DATABASE_URL" | cut -d "@" -f2 | cut -d "/" -f1 | cut -d ":" -f2)
  # if port wasn't specified, use default PG port
  if [ "$db_port" = "$db_host" ]; then
    db_port=5432
  fi
fi

if [ -z "${db_host}" ]; then
  echo "No database host information found; skipping db setup"
else
  if [ -z "${db_port}" ]; then
    db_port=5432
  fi

  while ! nc -z "$db_host" "$db_port"
  do
    echo "waiting for postgresql"
    sleep 1
  done

  if [ -z "${DATABASE_COMMAND}" ]; then
    echo "DATABASE_COMMAND is not supplied, skipping database rake tasks"
  else
    # Support env var option for database command(s)
    for db_command in $DATABASE_COMMAND; do
      bundle exec rake "$db_command"
    done
  fi
fi

# Then exec the container's main process
# This is what's set as CMD in a) Dockerfile b) compose c) CI
exec "$@"
