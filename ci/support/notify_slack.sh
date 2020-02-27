#!/usr/bin/env sh
# Sends Slack notification ERROR_MSG to webhook defined channel
# An env. variable CI_SLACK_WEBHOOK_URL needs to be set.

ERROR_MSG=$1

if [ -z "$ERROR_MSG" ] || [ -z "$CI_SLACK_WEBHOOK_URL" ]; then
    echo "Missing argument - Use: $0 message"
    echo "and set CI_SLACK_WEBHOOK_URL environment variable."
else
  curl -X POST -H 'Content-type: application/json' --data '{"text":"'"$ERROR_MSG"'"}' "$CI_SLACK_WEBHOOK_URL"
fi
