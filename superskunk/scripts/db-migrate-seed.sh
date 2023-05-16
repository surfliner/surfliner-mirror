#!/bin/sh
set -e

db-wait.sh "$DB_HOST:$DB_PORT"

echo "Ensuring database: $POSTGRESQL_DATABASE exists"
psql -tc "SELECT 1 FROM pg_database WHERE datname = '$POSTGRESQL_DATABASE'" \
     postgres://"$DB_USERNAME":"$DB_PASSWORD"@"$DB_HOST"/"$POSTGRESQL_DATABASE" | \
  grep -q 1 || \
  createdb -e -w "$POSTGRESQL_DATABASE" \
           postgres://"$DB_USERNAME":"$DB_PASSWORD"@"$DB_HOST"/"$POSTGRESQL_DATABASE"

bundle exec sequel -m ../db/sequel postgres://"$DB_USERNAME":"$DB_PASSWORD"@"$DB_HOST"/"$POSTGRESQL_DATABASE"
