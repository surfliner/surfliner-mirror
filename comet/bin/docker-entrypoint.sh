#!/bin/sh
set -e

mkdir -p /home/comet/app/tmp/pids
rm -f /home/comet/app/tmp/pids/*

# Run the command
exec "$@"
