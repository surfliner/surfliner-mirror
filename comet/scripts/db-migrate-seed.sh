#!/bin/sh
set -e

# shellcheck source=/dev/null
. db-setup.sh

bundle exec sequel -m db/sequel postgres://"$DB_USERNAME":"$DB_PASSWORD"@"$DB_HOST"/"$METADATA_DATABASE_NAME"

db-wait.sh "$SOLR_HOST:$SOLR_PORT"

while ! curl --silent "$SOLR_URL/admin/ping" | grep -q 'OK'
do
  echo "Waiting for Solr core/collection to be pingable on $SOLR_HOST:$SOLR_PORT"
  sleep 10
done

bundle exec rails db:seed
