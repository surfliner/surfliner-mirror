FROM ruby:2.6.2-alpine

RUN uname -a
RUN echo 'http://mirror.leaseweb.com/alpine/latest-stable/main' > /etc/apk/repositories; \
    echo 'http://mirror.leaseweb.com/alpine/latest-stable/community' >> /etc/apk/repositories
RUN cat /etc/apk/repositories

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
