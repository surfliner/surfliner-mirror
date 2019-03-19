#!/bin/bash
set -e

# Exit if the CI environment variables are not set
for var in SOLR_CORE_NAME SOLR_CONFIG_DIR REPOSITORY_URL ; do
  if [ -z "${!var}" ] ; then
    skip_solr_ci="true"
  fi
done

# Check if Solr core already exists
# Common in local testing w/ docker-compose
if [ -d "/opt/solr/server/solr/mycores/$SOLR_CORE_NAME" ]; then
  skip_solr_ci="true"
fi

if [ -z "$skip_solr_ci" ] ; then
  git clone "$REPOSITORY_URL" /tmp/repo
  cd /tmp/repo

  if [ "$SOLR_CONFIG_COMMIT_SHA" ] ; then
    git checkout "$SOLR_CONFIG_COMMIT_SHA"
  fi

  echo "Creating Solr core: $SOLR_CORE_NAME..."
  coresdir="/opt/solr/server/solr/mycores"
  mkdir -p $coresdir
  coredir="$coresdir/$SOLR_CORE_NAME"

  if [[ ! -d $coredir ]]; then
    mkdir  -p "$coredir"
    cp -r "/tmp/repo/$SOLR_CONFIG_DIR" "$coredir/conf"
    touch "$coredir/core.properties"
    echo "Successfully created $SOLR_CORE_NAME"
  else
      echo "Core $SOLR_CORE_NAME already exists"
  fi
else
  echo "CI Environment varaibles not set. Proceding with Solr startup..."
fi
