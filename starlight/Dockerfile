FROM ruby:2.5.3-alpine

RUN apk --no-cache upgrade && \
  apk add --no-cache \
  build-base \
  git \
  imagemagick \
  libxml2-dev \
  libxslt-dev \
  nodejs-current \
  postgresql-dev \
  sqlite-dev \
  tzdata \
  yarn

RUN mkdir -p /bundle
ENV BUNDLE_PATH=/bundle \
    BUNDLE_BIN=/bundle/bin \
    GEM_HOME=/bundle
ENV PATH="${BUNDLE_BIN}:${PATH}"

RUN mkdir -p /app
WORKDIR /app
COPY . .

ENTRYPOINT ["/bin/sh", "/app/docker/docker-entrypoint.sh"]

