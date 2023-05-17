#!/bin/sh
set -e

db-wait.sh "$POSTGRESQL_HOST:$POSTGRESQL_PORT"

database_url="postgres://${POSTGRESQL_USERNAME}:${POSTGRESQL_PASSWORD}@${POSTGRESQL_HOST}/${POSTGRESQL_DATABASE}"

echo "Ensuring database: $POSTGRESQL_DATABASE exists"
psql -tc "SELECT 1 FROM pg_database WHERE datname = '$POSTGRESQL_DATABASE'" "$database_url" | \
  grep -q 1 || \
  createdb -e -w "$POSTGRESQL_DATABASE" "$database_url"

bundle exec sequel -m ../db/sequel "$database_url"
