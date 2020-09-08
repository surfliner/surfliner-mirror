#!/usr/bin/env sh
set -e

echo "Restoring $DIRECTORY_IMPORT_PATH directory..."
aws --endpoint-url "$ENDPOINT_URL" s3 sync "s3://$BUCKET/$DIRECTORY_BUCKET_PATH" "$DIRECTORY_IMPORT_PATH"
