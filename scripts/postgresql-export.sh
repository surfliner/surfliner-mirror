#!/usr/bin/env sh
set -e

# Map bitnami PG env var names to postgresql-client env var names
export PGPASSWORD="${POSTGRES_PASSWORD}"
export PGHOST="${POSTGRES_HOST}"
export PGUSER="${POSTGRES_USER}"
export PGUSER="${POSTGRES_USER:-postgres}"
export PGDATABASE="${POSTGRES_DB}"

# Map from configmap for Starlight
export ENDPOINT_URL="${S3_ENDPOINT}"
export AWS_DEFAULT_REGION="${AWS_REGION}"

# Ensure we can interact with the database
while ! nc -z "$PGHOST" 5432
do
  echo "waiting for postgresql"
  sleep 1
done

echo "Creating database backup for $PGDATABASE..."
pg_dump -Fc -f "$DB_BACKUP_SOURCE"
echo "Uploading database backup to S3/Minio bucket..."
if [ -z "$ENDPOINT_URL" ]; then
  aws s3 cp "$DB_BACKUP_SOURCE" "$DB_BACKUP_DESTINATION"
else
  aws --endpoint-url "$ENDPOINT_URL" s3 cp "$DB_BACKUP_SOURCE" "$DB_BACKUP_DESTINATION"
fi
