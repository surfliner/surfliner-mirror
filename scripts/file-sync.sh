#!/usr/bin/env sh
set -e

echo "Syncing $SOURCE_PATH files to $DESTINATION_PATH"
aws --endpoint-url "$ENDPOINT_URL" s3 sync "$SOURCE_PATH" "$DESTINATION_PATH"
