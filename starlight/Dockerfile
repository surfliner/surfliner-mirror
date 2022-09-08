# renovate: datasource=docker depName=alpine
ARG ALPINE_VERSION=3.16
# renovate: datasource=docker depName=ruby versioning=ruby
ARG RUBY_VERSION=2.7.6

# these ARGs are used by the ONBUILD commands in the base image
ARG BUILD_TIME_APKS='build-base gcompat git libxml2-dev libxslt-dev nodejs postgresql-dev shared-mime-info tzdata'
ARG LOCAL_PROJECT=starlight
FROM registry.gitlab.com/surfliner/surfliner/base:latest as starlight-base


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


# these ARGs are used by the ONBUILD commands in the base image
ARG LOCAL_PROJECT=starlight
ARG RUN_TIME_APKS='curl imagemagick libpq nodejs tini tzdata zip'
FROM registry.gitlab.com/surfliner/surfliner/prod:latest as starlight-prod
COPY --from=starlight-build --chown=$UID:$GID ${DOCKER_PROJECT}/public/assets ${DOCKER_PROJECT}/public/assets
COPY --from=starlight-build --chown=$UID:$GID ${DOCKER_PROJECT}/vendor ${DOCKER_PROJECT}/vendor

RUN bundle config set deployment 'true'
RUN bundle config set without 'test development'
ENV BUNDLE_PATH="${DOCKER_PROJECT}/vendor/bundle"


FROM starlight-base as starlight-dev
ARG LOCAL_PROJECT=starlight
ARG DOCKER_ROOT=/home/${LOCAL_PROJECT}
ARG DOCKER_PROJECT=${DOCKER_ROOT}/app

RUN apk --no-cache add \
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
