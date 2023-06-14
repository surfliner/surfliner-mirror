#!/bin/sh
set -e

# shellcheck source=/dev/null
. db-setup.sh

bundle exec sequel -m db/sequel postgres://"$DB_USERNAME":"$DB_PASSWORD"@"$DB_HOST"/"$METADATA_DATABASE_NAME"

db-wait.sh "$SOLR_HOST:$SOLR_PORT"

while ! curl --silent "http://$SOLR_ADMIN_USER:$SOLR_ADMIN_PASSWORD@$SOLR_HOST:$SOLR_PORT/solr/$SOLR_COLLECTION_NAME/admin/ping" | grep -q 'OK'
do
  echo "Waiting for Solr core/collection to be pingable on http://$SOLR_ADMIN_USER:REDACTED@$SOLR_HOST:$SOLR_PORT/solr/$SOLR_COLLECTION_NAME/admin/ping"
  sleep 10
done

bundle exec rails db:seed
