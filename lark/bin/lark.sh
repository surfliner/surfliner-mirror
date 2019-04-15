#!/bin/sh

if [ $EVENT_ADAPTER == "sql" ]
then
  while ! nc -z $POSTGRES_HOST $POSTGRES_PORT;
  do
    echo "waiting for postgresql";
    sleep 1;
  done;
fi

bundle exec rake db:migrate &&
  bundle exec rackup --host 0.0.0.0 -p 5000
