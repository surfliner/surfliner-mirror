#!/bin/sh
set -e

PGPASSWORD=$DB_PASSWORD
PGHOST=$DB_HOST
PGUSER=$DB_USERNAME
PGDATABASE=$DB_NAME
export PGPASSWORD PGHOST PGUSER PGDATABASE

db-wait.sh "$DB_HOST:$DB_PORT"

echo "Ensuring database: $METADATA_DATABASE_NAME exists"
psql -tc "SELECT 1 FROM pg_database WHERE datname = '$METADATA_DATABASE_NAME'" | grep -q 1 || createdb -e -w "$METADATA_DATABASE_NAME"

bundle exec sequel -m ../db/sequel postgres://"$DB_USERNAME":"$DB_PASSWORD"@"$DB_HOST"/"$METADATA_DATABASE_NAME"
