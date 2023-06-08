#!/bin/sh
set -e

# Get DB host and port
if [ -z "${DATABASE_URL}" ]; then
  db_host=${POSTGRESQL_HOST}
  db_port=${POSTGRESQL_PORT}
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

  db-wait.sh "$db_host:$db_port"

  if [ -z "${DATABASE_COMMAND}" ]; then
    echo "DATABASE_COMMAND is not supplied, skipping database rake tasks"
  else
    for db_command in $DATABASE_COMMAND; do
      bundle exec rake "$db_command"
    done
  fi
fi
