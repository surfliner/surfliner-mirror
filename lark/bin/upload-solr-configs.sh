#!/usr/bin/env sh

COUNTER=0;

while [ $COUNTER -lt 30 ]; do
  echo "-- Looking for ZK (${ZK_HOST}:${ZK_PORT})..."
  if echo srvr | nc "${ZK_HOST}" "${ZK_PORT}" | grep -q "Mode"; then
    echo "-- Uploading solrconfig.xml and schema.xml to ZooKeeper ..."
    bundle exec rake solrconf:upload['solr/config']
    exit 0
  fi
  COUNTER=$(( COUNTER+1 ));
  sleep 5s
done

echo "--- ERROR: failed to connect to ZooKeeper after 5 minutes";
exit 1
