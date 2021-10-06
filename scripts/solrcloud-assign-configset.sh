#!/usr/bin/env sh

COUNTER=0;

if [ "$SOLR_ADMIN_USER" ]; then
  solr_user_settings="--user $SOLR_ADMIN_USER:$SOLR_ADMIN_PASSWORD"
fi

solr_config_name="${SOLR_CONFIG_NAME:-solrconfig}"
solr_collection_name="${SOLR_CORE_NAME:-collection1}"

# Solr Cloud Collection API URLs
solr_collection_list_url="$SOLR_HOST:$SOLR_PORT/solr/admin/collections?action=LIST"
solr_collection_modify_url="$SOLR_HOST:$SOLR_PORT/solr/admin/collections?action=MODIFYCOLLECTION&collection=$solr_collection_name&collection.configName=$solr_config_name"

while [ $COUNTER -lt 30 ]; do
  echo "-- Looking for Solr (${SOLR_HOST}:${SOLR_PORT})..."
  if nc -z "${SOLR_HOST}" "${SOLR_PORT}"; then
    # shellcheck disable=SC2143,SC2086
    echo $solr_collection_name
    echo $solr_user_settings
    echo $solr_collection_modify_url
    if curl --silent $solr_user_settings "$solr_collection_list_url" | grep -q "${solr_collection_name}"; then
      echo "-- Collection ${solr_collection_name} exists; setting ConfigSet ..."
      curl $solr_user_settings "$solr_collection_modify_url"
      exit
    fi
  fi
  COUNTER=$(( COUNTER+1 ));
  sleep 5s
done

echo "--- ERROR: failed to create/update Solr collection after 5 minutes";
exit 1
