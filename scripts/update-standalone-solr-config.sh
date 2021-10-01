#!/bin/bash
 
# This script determines if solr configuration files have changed between what is on this server
# and what is available in the shoreline git repository.
#
# This is done by comparing md5sums representing all contents of the directories. If they are different
# then we need to sync the files from the git repo to the solr core config directory.
 
SOLR_DATA_DIR="/var/solr/data"
SOLR_CORE="shoreline"
SOLR_CORE_CONF_DIR="${SOLR_DATA_DIR}/${SOLR_CORE}/conf"
 
GIT_REPO_URL="https://gitlab.com/surfliner/surfliner.git"
GIT_REPO_SOLR_CONF_PATH="shoreline/discovery/solr/conf"
GIT_REPO_CLONE_PATH="/opt/surfliner"
 
# Clone git repo to local server
git clone -q ${GIT_REPO_URL} ${GIT_REPO_CLONE_PATH}
 
# Remove the core.properties files in the git repo solr conf dir
rm -f ${GIT_REPO_CLONE_PATH}/${GIT_REPO_SOLR_CONF_PATH}/core.properties
 
# Get MD5 sum of git repo solr configuration
GIT_SOLR_MD5=$(find ${GIT_REPO_CLONE_PATH}/${GIT_REPO_SOLR_CONF_PATH} -type f -exec md5sum {} + | awk '{print $1}' | LC_ALL=C sort -k 2 | md5sum | awk '{print $1}')
 
# Get MD5 sum of local solr configuration
LOCAL_SOLR_MD5=$(find ${SOLR_CORE_CONF_DIR} -type f -exec md5sum {} + | awk '{print $1}' | LC_ALL=C sort -k 2 | md5sum | awk '{print $1}')
 
# If MD5 hashes do not match, then solr config files need to be synchronized
if [[ "${GIT_SOLR_MD5}" != "${LOCAL_SOLR_MD5}" ]] ; then
  rsync -a --delete ${GIT_REPO_CLONE_PATH}/${GIT_REPO_SOLR_CONF_PATH}/ ${SOLR_CORE_CONF_DIR}/
  chown -R solr:solr ${SOLR_CORE_CONF_DIR}/
  /etc/init.d/solr restart
fi
 
rm -rf ${GIT_REPO_CLONE_PATH}
