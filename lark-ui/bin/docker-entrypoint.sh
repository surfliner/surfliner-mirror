#!/bin/sh
set -e

# Exec the container's main process
# This is what's set as CMD in a) Dockerfile b) compose c) CI
exec "$@"
