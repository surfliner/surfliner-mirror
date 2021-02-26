#!/usr/bin/env sh

COUNTER=0;

if [ "$SOLR_ADMIN_USER" ]; then
  solr_user_settings="--user $SOLR_ADMIN_USER:$SOLR_ADMIN_PASSWORD"
fi

# Solr Cloud Collection API URLs
solr_collection_status_url="$SOLR_HOST:$SOLR_PORT/api/collections?action=COLSTATUS"
solr_collection_modify_url="$SOLR_HOST:$SOLR_PORT/solr/admin/collections?action=MODIFYCOLLECTION&collection=$SOLR_CORE_NAME&collection.configName=solrconfig"

while [ $COUNTER -lt 30 ]; do
  echo "-- Looking for Solr (${SOLR_HOST}:${SOLR_PORT})..."
  if nc -z "${SOLR_HOST}" "${SOLR_PORT}"; then
    # shellcheck disable=SC2143
    if curl --silent $solr_user_settings "$solr_collection_status_url" | grep -q "${SOLR_CORE_HAME}"; then
      echo "-- Collection ${SOLR_CORE_NAME} exists; setting Starlight ConfigSet ..."
      curl $solr_user_settings "$solr_collection_modify_url" || exit 1
      exit 0
    fi
  fi
  COUNTER=$(( COUNTER+1 ));
  sleep 5s
done

echo "--- ERROR: failed to create/update Solr collection after 5 minutes";
exit 1
