#!/bin/sh
set -e

# shellcheck source=/dev/null
. db-setup.sh

bundle exec sequel -m db/sequel postgres://"$DB_USERNAME":"$DB_PASSWORD"@"$DB_HOST"/"$METADATA_DATABASE_NAME"

db-wait.sh "$SOLR_HOST:$SOLR_PORT"

bundle exec rails db:seed
