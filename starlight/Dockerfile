# renovate: datasource=docker depName=alpine
ARG ALPINE_VERSION=3.15
# renovate: datasource=docker depName=ruby versioning=ruby
ARG RUBY_VERSION=2.7.6

FROM ruby:$RUBY_VERSION-alpine$ALPINE_VERSION as starlight-base
# the directory of the host system from which application files are copied
ARG LOCAL_PROJECT=starlight
ARG DOCKER_ROOT=/home/${LOCAL_PROJECT}
# the project path on the image
ARG DOCKER_PROJECT=${DOCKER_ROOT}/app
WORKDIR ${DOCKER_PROJECT}

# build-time dependencies only
RUN apk --no-cache upgrade && \
  apk --no-cache add \
  build-base \
  gcompat \
  git \
  libxml2-dev \
  libxslt-dev \
  nodejs \
  postgresql-dev \
  shared-mime-info \
  tzdata \
  yarn

COPY ${LOCAL_PROJECT}/Gemfile* ${DOCKER_PROJECT}/
COPY gems ${DOCKER_ROOT}/gems/

FROM starlight-base as starlight-build
# used in ruby-bundle-cleanup.sh for locating the bundle cache
ENV RUBY_ABI=2.7.0

ARG LOCAL_PROJECT=starlight
ARG DOCKER_ROOT=/home/${LOCAL_PROJECT}
# used in ruby-bundle-cleanup.sh
ENV DOCKER_PROJECT=${DOCKER_ROOT}/app

COPY scripts/docker/*.sh ${DOCKER_PROJECT}/
RUN ${DOCKER_PROJECT}/ruby-bundle-prod.sh
RUN ${DOCKER_PROJECT}/ruby-bundle-cleanup.sh

COPY $LOCAL_PROJECT $DOCKER_PROJECT

RUN \
  APP_URL='http://localhost' \
  DATABASE_URL='postgresql://fake' \
  REDIS_URL='redis://redis:6379' \
  DB_ADAPTER=nulldb \
  SKIP_TRANSLATION=yes \
  bundle exec rake assets:precompile

FROM ruby:$RUBY_VERSION-alpine$ALPINE_VERSION as starlight-prod
ARG GID=10001
ARG UID=10000

ARG LOCAL_PROJECT=starlight
ARG DOCKER_ROOT=/home/${LOCAL_PROJECT}
ARG DOCKER_PROJECT=${DOCKER_ROOT}/app
WORKDIR ${DOCKER_PROJECT}

# run-time dependencies only
RUN apk --no-cache upgrade && \
  apk --no-cache add \
  curl \
  imagemagick \
  libpq \
  nodejs \
  tini \
  tzdata \
  zip

RUN addgroup -S --gid $GID app && \
  adduser -S -G app -u $UID -s /bin/sh -h /app app
USER app

COPY --chown=$UID:$GID gems ${DOCKER_ROOT}/gems/
COPY --chown=$UID:$GID $LOCAL_PROJECT $DOCKER_PROJECT
COPY --chown=$UID:$GID scripts/* $DOCKER_PROJECT/scripts/
ENV PATH="${DOCKER_PROJECT}/scripts:${PATH}"

COPY --from=starlight-build --chown=$UID:$GID ${DOCKER_PROJECT}/public/assets ${DOCKER_PROJECT}/public/assets
COPY --from=starlight-build --chown=$UID:$GID ${DOCKER_PROJECT}/public/uv ${DOCKER_PROJECT}/public/uv
COPY --from=starlight-build --chown=$UID:$GID ${DOCKER_PROJECT}/vendor ${DOCKER_PROJECT}/vendor

RUN bundle config set deployment 'true'
RUN bundle config set without 'test development'
ENV BUNDLE_PATH="${DOCKER_PROJECT}/vendor/bundle"

# TODO: should these be set by helm/docker-compose?
ENV RAILS_ROOT=${DOCKER_PROJECT}
ENV RAILS_SERVE_STATIC_FILES=1
ENTRYPOINT ["tini", "--", "bin/docker-entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:3000"]

FROM starlight-base as starlight-dev
ARG LOCAL_PROJECT=starlight
ARG DOCKER_ROOT=/home/${LOCAL_PROJECT}
ARG DOCKER_PROJECT=${DOCKER_ROOT}/app

RUN apk --no-cache upgrade && \
  apk --no-cache add \
  curl \
  imagemagick \
  libpq \
  nodejs \
  tzdata \
  zip
RUN bundle install --jobs "$(nproc)"

COPY $LOCAL_PROJECT $DOCKER_PROJECT

COPY scripts/* ${DOCKER_ROOT}/scripts/
ENV PATH="${DOCKER_ROOT}/scripts:${PATH}"

ENV RAILS_ROOT=${DOCKER_PROJECT}
ENV RAILS_SERVE_STATIC_FILES=1

RUN \
  DATABASE_URL='postgresql://fake' \
  DB_ADAPTER=nulldb \
  SKIP_TRANSLATION=yes \
  bundle exec rake assets:precompile

ENTRYPOINT ["bin/docker-entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:3000"]
