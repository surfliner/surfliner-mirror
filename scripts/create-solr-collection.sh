#!/usr/bin/env sh

COUNTER=0;

while [ $COUNTER -lt 30 ]; do
  echo "-- Looking for Solr (${SOLR_HOST}:${SOLR_PORT})..."
  if nc -z "${SOLR_HOST}" "${SOLR_PORT}"; then
    # shellcheck disable=SC2143
    if [ ! "$(curl "${SOLR_HOST}:${SOLR_PORT}/api/collections?action=COLSTATUS" | grep -q "${SOLR_CORE_HAME}")" ]; then
      echo "-- Collection ${SOLR_CORE_NAME} does not exist; creating ..."
      curl -H 'Content-type: application/json' -d "{create: {name: ${SOLR_CORE_NAME}, config: solrconfig, numShards: 1}}" "${SOLR_HOST}:${SOLR_PORT}/api/collections/"
    fi
    exit 0
  fi
  COUNTER=$(( COUNTER+1 ));
  sleep 5s
done

echo "--- ERROR: failed to create Solr core after 5 minutes";
exit 1
