#!/usr/bin/env sh
set -e

echo "Downloading $PGDATABASE database backup..."
if [ -z "$ENDPOINT_URL" ]; then
  aws s3 cp "$DB_BACKUP_SOURCE" "$DB_BACKUP_DESTINATION"
else
  aws --endpoint-url "$ENDPOINT_URL" s3 cp "$DB_BACKUP_SOURCE" "$DB_BACKUP_DESTINATION"
fi
# Ensure we can interact with the database
while ! nc -z "$PGHOST" 5432
do
  echo "waiting for postgresql"
  sleep 1
done

echo "Restoring database backup $PGDATABASE"
pg_restore \
  --clean \
  --if-exists \
  --verbose \
  -U "$PGUSER" \
  --no-owner \
  --role="$PGUSER" \
  -d "$PGDATABASE" \
  "$DB_BACKUP_DESTINATION"

if [ -n "${PG_RUNTIME_USER}" ]; then
  psql -U "${PGUSER}" <<EOF
    GRANT ALL PRIVILEGES ON "${PGDATABASE}" TO ${PG_RUNTIME_USER};
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${PG_RUNTIME_USER};
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ${PG_RUNTIME_USER};
    ALTER DEFAULT PRIVILEGES FOR USER ${PG_RUNTIME_USER} "${PGDATABASE}" OWNER TO ${PG_RUNTIME_USER} GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ${PG_RUNTIME_USER};
EOF
fi
