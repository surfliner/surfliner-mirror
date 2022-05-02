#!/bin/sh

if [ -z "${DOCKER_PROJECT+x}" ]; then
  echo "--- ERROR: missing DOCKER_PROJECT variable"
  exit 1
fi

if [ -z "${RUBY_ABI+x}" ]; then
  echo "--- ERROR: missing RUBY_ABI variable"
  exit 1
fi

rm -rf "$DOCKER_PROJECT/vendor/bundle/ruby/$RUBY_ABI/cache"
# gems installed with git include their entire history, which can be very large
find "$DOCKER_PROJECT/vendor" -name ".git" -type d -print0 | xargs -n1 rm -rf
