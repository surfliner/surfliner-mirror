#!/bin/sh
set -e

db-wait.sh "$DB_HOST:$DB_PORT"
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec sequel -m db/sequel postgres://"$DB_USERNAME":"$DB_PASSWORD"@"$DB_HOST"/"$METADATA_DATABASE_NAME"

db-wait.sh "$SOLR_HOST:$SOLR_PORT"

bundle exec rails db:seed
