#!/usr/bin/env sh

solr_core_status_url="http://${SOLR_HOST}:${SOLR_PORT}/solr/admin/cores?action=STATUS&core=${SOLR_CORES}&indexInfo=false"

counter=0;
while [ $counter -lt 30 ]; do
  echo "-- Looking for Solr (${SOLR_HOST}:${SOLR_PORT})..."
  if nc -z "${SOLR_HOST}" "${SOLR_PORT}"; then
    if curl -s "$solr_core_status_url" | grep -q "startTime"; then
      echo "--- SUCCESS: Solr core: ${SOLR_CORES} is ready"
      exit 0
    else
      echo "--- Solr core: ${SOLR_CORES} is not ready"
    fi
  fi
  counter=$(( counter+1 ));
  sleep 2s
done

echo "--- ERROR: failed to get successful STATUS check for Solr core: ${SOLR_CORES}";
exit 1
