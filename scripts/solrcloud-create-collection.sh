#!/usr/bin/env sh

COUNTER=0;

if [ "$SOLR_ADMIN_USER" ]; then
  solr_user_settings="--user $SOLR_ADMIN_USER:$SOLR_ADMIN_PASSWORD"
fi

solr_config_name="${SOLR_CONFIGSET_NAME:-solrconfig}"
solr_collection_name="${SOLR_COLLECTION_NAME:-collection1}"
solr_collection_shards="${SOLR_COLLECTION_SHARDS:-2}"

# Solr Cloud Collection API URLs
solr_config_list_url="http://$SOLR_HOST:$SOLR_PORT/api/cluster/configs?omitHeader=true"
solr_collection_create_url="$SOLR_HOST:$SOLR_PORT/solr/admin/collections?action=CREATE&name=$solr_collection_name&collection.configName=$solr_config_name&numShards=$solr_collection_shards"

while [ $COUNTER -lt 30 ]; do
  echo "-- Looking for Solr (${SOLR_HOST}:${SOLR_PORT})..."
  if nc -z "${SOLR_HOST}" "${SOLR_PORT}"; then
    # shellcheck disable=SC2143,SC2086
    echo $solr_collection_name
    echo $solr_user_settings
    echo $solr_collection_create_url
    if curl --silent $solr_user_settings "$solr_config_list_url" | grep -q "${solr_config_name}"; then
      echo "-- ConfigSet $solr_config_name exists; creating Collection $solr_collection_name ..."
      curl $solr_user_settings "$solr_collection_create_url"
      exit
    fi
  fi
  COUNTER=$(( COUNTER+1 ));
  sleep 5s
done

echo "--- ERROR: failed to create/update Solr collection after 5 minutes";
exit 1
