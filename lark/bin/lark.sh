#!/bin/sh

if [ $EVENT_ADAPTER == "sql" ]
then
  while ! nc -z $POSTGRES_HOST $POSTGRES_PORT;
  do
    echo "waiting for postgresql";
    sleep 1;
  done;

  bundle exec rake db:migrate
fi

bundle exec puma -b tcp://0.0.0.0:5000
