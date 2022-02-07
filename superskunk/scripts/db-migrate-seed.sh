#!/bin/sh
set -e

db-wait.sh "$DB_HOST:$DB_PORT"
bundle exec sequel -m ../db/sequel postgres://"$DB_USERNAME":"$DB_PASSWORD"@"$DB_HOST"/"$METADATA_DATABASE_NAME"
