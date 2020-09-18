#!/usr/bin/env sh
set -e

# Ensure we can interact with the database
while ! nc -z "$PGHOST" 5432
do
  echo "waiting for postgresql"
  sleep 1
done

echo "Creating database backup for $PGDATABASE..."
pg_dump -Fc -f "$DB_BACKUP_SOURCE"
echo "Uploading database backup to S3/Minio bucket..."
aws --endpoint-url "$ENDPOINT_URL" s3 cp "$DB_BACKUP_SOURCE" "$DB_BACKUP_DESTINATION"
