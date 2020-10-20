#!/bin/sh

COUNTER=0
while [ $COUNTER -lt 60 ]; do
  echo "Waiting for Lark to start at $APP_URL ..."

  STATUS=$(curl -s -o /dev/null -w "%{http_code}\n" "$APP_URL")
  if [ $STATUS == '200' ]; then
    echo "Importing data for lark ..."

    bundle exec rake lark:seed

    exit 0
  fi
  COUNTER=$(( COUNTER+1 ));
  sleep 3s
done;
echo "ERROR: Lark failed to start after 180 seconds"
exit 1
