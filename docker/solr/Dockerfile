FROM solr:7.1-alpine

USER root

RUN apk --no-cache upgrade && \
  apk add --no-cache \
  git

USER $SOLR_USER

COPY ./setup.sh /docker-entrypoint-initdb.d/
