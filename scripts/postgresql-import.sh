#!/usr/bin/env sh
set -e

echo "Downloading $PGDATABASE database backup..."
aws --endpoint-url "$ENDPOINT_URL" s3 cp "s3://$BUCKET/$DB_BUCKET_KEY" "$DB_BACKUP_FILE"

# Ensure we can interact with the database
while ! nc -z "$PGHOST" 5432
do
  echo "waiting for postgresql"
  sleep 1
done

echo "Restoring database backup $PGDATABASE"
pg_restore --clean --single-transaction --verbose -U "$PGUSER" -d "$PGDATABASE" "$DB_BACKUP_FILE"
