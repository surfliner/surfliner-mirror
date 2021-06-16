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
