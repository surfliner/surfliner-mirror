#!/usr/bin/env sh

COUNTER=0;
# /home/comet/app/solr/conf
CONFDIR="${1}"

if [ "$SOLR_ADMIN_USER" ]; then
  solr_user_settings="--user $SOLR_ADMIN_USER:$SOLR_ADMIN_PASSWORD"
fi

solr_config_name="${SOLR_CONFIGSET_NAME:-solrconfig}"

# Solr Cloud ConfigSet API URLs
solr_config_list_url="http://$SOLR_HOST:$SOLR_PORT/api/cluster/configs?omitHeader=true"
solr_config_upload_url="http://$SOLR_HOST:$SOLR_PORT/solr/admin/configs?action=UPLOAD&name=${solr_config_name}"

while [ $COUNTER -lt 30 ]; do
  echo "-- Looking for Solr (${SOLR_HOST}:${SOLR_PORT})..."
  if nc -z "${SOLR_HOST}" "${SOLR_PORT}"; then
    # the solr pods come up and report available before they are ready to accept trusted configs
    # only try to upload the config if auth is on.
    #
    # shellcheck disable=SC2143,SC2086
    if curl --silent --user 'fake:fake' "$solr_config_list_url" | grep -q '401'; then
      echo "-- Uploading ConfigSet for ${CONFDIR} ..."
      # shellcheck disable=SC2035,SC2086
      (cd "$CONFDIR" && zip -r - *) | curl -X POST $solr_user_settings --header "Content-Type:application/octet-stream" --data-binary @- "$solr_config_upload_url"
      exit
    else
      echo "-- Solr at $solr_config_list_url is accepting unauthorized connections; we can't upload a trusted ConfigSet."
      echo "--   It's possible SolrCloud is bootstrapping its configuration, so this process will retry."
      echo "--   see: https://solr.apache.org/guide/8_6/configsets-api.html#configsets-upload"
    fi
  fi
  COUNTER=$(( COUNTER+1 ));
  sleep 5s
done

echo "--- ERROR: failed to create Solr ConfigSet after 5 minutes";
exit 1
