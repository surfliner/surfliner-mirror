#!/bin/sh

EXISTING_DB="$(psql -tAc 'SELECT datname from pg_database' | grep "${PGDATABASE}")"

if [ "${EXISTING_DB}" = "${PGDATABASE}" ]; then
  echo "-- Database ${PGDATABASE} already exists, skipping"
else
  echo "-- Creating database ${PGDATABASE}"
  createdb --owner "${PGOWNER}" "${PGDATABASE}"
fi
