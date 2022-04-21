#!/bin/sh
set -e

db_wait () {
  host=$(printf "%s\n" "$1"| cut -d : -f 1)
  port=$(printf "%s\n" "$1"| cut -d : -f 2)

  shift 1

  while ! nc -z "$host" "$port"
  do
    echo "waiting for $host:$port"
    sleep 1
  done

  exec "$@"
}

db_wait "$DB_HOST:$DB_PORT"
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec sequel -m db/sequel postgres://"$DB_USERNAME":"$DB_PASSWORD"@"$DB_HOST"/"$METADATA_DATABASE_NAME"

db_wait "$SOLR_HOST:$SOLR_PORT"

bundle exec rails db:seed
