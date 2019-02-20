#!/bin/bash
set -e

# Exit if the CI environment variables are not set
for var in SOLR_CORE_NAME SOLR_CONFIG_DIR CI_REPOSITORY_URL CI_COMMIT_SHA ; do
  if [ -z "${!var}" ] ; then
    skip_solr_ci="true"
  fi
done

if [ -z "$skip_solr_ci" ] ; then
  git clone "$CI_REPOSITORY_URL" /tmp/repo
  cd /tmp/repo
  git checkout "$CI_COMMIT_SHA"

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

