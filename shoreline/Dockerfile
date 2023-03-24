# renovate: datasource=docker depName=alpine
ARG ALPINE_VERSION=3.16
# renovate: datasource=docker depName=ruby versioning=ruby
ARG RUBY_VERSION=2.7.7

# see ../docker/base/Dockerfile
ARG BASE_IMAGE=registry.gitlab.com/surfliner/surfliner/base-${RUBY_VERSION}
# see ../docker/prod/Dockerfile
ARG PROD_IMAGE=registry.gitlab.com/surfliner/surfliner/prod-${RUBY_VERSION}

# these ARGs are used by the ONBUILD commands in the base image
ARG BUILD_TIME_APKS='build-base libxml2-dev libxslt-dev nodejs postgresql-dev shared-mime-info yarn'
ARG LOCAL_PROJECT=shoreline
FROM $BASE_IMAGE:latest as shoreline-base


FROM shoreline-base as shoreline-build
# used in ruby-bundle-cleanup.sh for locating the bundle cache
ENV RUBY_ABI=2.7.0

ARG LOCAL_PROJECT=shoreline
ARG DOCKER_ROOT=/home/${LOCAL_PROJECT}
# used in ruby-bundle-cleanup.sh
ENV DOCKER_PROJECT=${DOCKER_ROOT}/app

COPY scripts/docker/*.sh ${DOCKER_PROJECT}/
RUN ${DOCKER_PROJECT}/ruby-bundle-prod.sh
RUN ${DOCKER_PROJECT}/ruby-bundle-cleanup.sh

COPY $LOCAL_PROJECT $DOCKER_PROJECT
RUN bundle exec rake assets:precompile


# these ARGs are used by the ONBUILD commands in the base image
ARG LOCAL_PROJECT=shoreline
ARG RUN_TIME_APKS='curl libpq nodejs shared-mime-info tini tzdata zip'
FROM $PROD_IMAGE:latest as shoreline-prod

COPY --from=shoreline-build --chown=$UID:$GID ${DOCKER_PROJECT}/public/assets ${DOCKER_PROJECT}/public/assets
COPY --from=shoreline-build --chown=$UID:$GID ${DOCKER_PROJECT}/vendor ${DOCKER_PROJECT}/vendor

RUN bundle config set deployment 'true'
RUN bundle config set without 'test development'
ENV BUNDLE_PATH="${DOCKER_PROJECT}/vendor/bundle"


FROM shoreline-base as shoreline-dev
ARG LOCAL_PROJECT=shoreline
ARG DOCKER_ROOT=/home/${LOCAL_PROJECT}
ARG DOCKER_PROJECT=${DOCKER_ROOT}/app

RUN apk --no-cache add \
  curl \
  less \
  libpq \
  nodejs \
  shared-mime-info \
  tzdata \
  zip

RUN gem update bundler
RUN bundle install --jobs "$(nproc)"

COPY $LOCAL_PROJECT $DOCKER_PROJECT

COPY scripts/* ${DOCKER_PROJECT}/scripts/
ENV PATH="${DOCKER_PROJECT}/scripts:${PATH}"

ENV RAILS_ROOT=${DOCKER_PROJECT}
ENV RAILS_SERVE_STATIC_FILES=1

RUN bundle exec rake assets:precompile

ENTRYPOINT ["bin/docker-entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:3000"]
