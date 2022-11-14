#!/bin/sh
COUNTER=0
while [ $COUNTER -lt 120 ]; do
  echo "-- Looking for GeoServer at ${GEOSERVER_INTERNAL_HOST}:${GEOSERVER_PORT} ..."
  if nc -z "${GEOSERVER_INTERNAL_HOST}" "${GEOSERVER_PORT}" ; then
    echo "-- Found GeoServer; ingesting..."

    # shellcheck disable=SC2102
    SHORELINE_FILE_ROOT=${*} bundle exec rake shoreline:ingest[spec/fixtures/csv/Ingest03.csv]

    exit $?
  fi
  COUNTER=$(( COUNTER+1 ));
  sleep 2s
done;
echo "--- ERROR: Failed to find GeoServer after 240 secs"
exit 1
