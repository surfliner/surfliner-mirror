#!/bin/sh
set -e

db-wait.sh "$POSTGRESQL_HOST:$POSTGRESQL_PORT"

psql_base="postgres://${POSTGRESQL_USERNAME}:${POSTGRESQL_PASSWORD}@${POSTGRESQL_HOST}"
database_url="${psql_base}/${POSTGRESQL_DATABASE}"

echo "Ensuring database: $POSTGRESQL_DATABASE exists"
psql -tc "SELECT 1 FROM pg_database WHERE datname = '$POSTGRESQL_DATABASE'" "$psql_base" | \
  grep -q 1 || \
  psql -tc "CREATE DATABASE ${POSTGRESQL_DATABASE};" "$psql_base"

bundle exec sequel -m ../db/sequel "$database_url"
