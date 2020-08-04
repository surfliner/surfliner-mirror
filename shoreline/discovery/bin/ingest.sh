#!/bin/sh

FILES=${*}

COUNTER=0
while [ $COUNTER -lt 120 ]; do
  echo "-- Looking for GeoServer at ${GEOSERVER_INTERNAL_HOST}:${GEOSERVER_PORT} ..."
  if nc -z "${GEOSERVER_INTERNAL_HOST}" "${GEOSERVER_PORT}" ; then
    echo "-- Found GeoServer; ingesting..."

    for shape in ${FILES}; do
      echo "-- Ingesting ${shape}..."
      bundle exec rake shoreline:publish["${shape}"]
    done

    exit 0
  fi
  COUNTER=$(( COUNTER+1 ));
  sleep 2s
done;
echo "--- ERROR: Failed to find GeoServer after 240 secs"
exit 1
