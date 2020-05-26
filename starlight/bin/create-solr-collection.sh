#!/usr/bin/env sh

COUNTER=0;

while [ $COUNTER -lt 120 ]; do
  if nc "${SOLR_HOST}" "${SOLR_PORT}"; then
    # shellcheck disable=SC2143
    if [ ! "$(curl "${SOLR_HOST}:${SOLR_PORT}/api/collections?action=COLSTATUS" | grep -q "${SOLR_CORE_HAME}")" ]; then
      echo "Collection ${SOLR_CORE_NAME} does not exist; creating ..."
      curl -H 'Content-type: application/json' -d "{create: {name: ${SOLR_CORE_NAME}, config: solrconfig, numShards: 1}}" "${SOLR_HOST}:${SOLR_PORT}/api/collections/"
    fi
    exit 0
  fi
  COUNTER=$(( COUNTER+1 ));
  sleep 2s
done

echo "Failed to create Solr core after 240 secs";
exit 1
