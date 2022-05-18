#!/usr/bin/env sh
set -e

# Map from configmap for Starlight
export ENDPOINT_URL="${S3_ENDPOINT}"
export AWS_DEFAULT_REGION="${AWS_REGION}"

echo "Syncing $SOURCE_PATH files to $DESTINATION_PATH"
if [ -z "$ENDPOINT_URL" ]; then
  aws s3 sync "$SOURCE_PATH" "$DESTINATION_PATH"
else
  aws --endpoint-url "$ENDPOINT_URL" s3 sync "$SOURCE_PATH" "$DESTINATION_PATH"
fi
