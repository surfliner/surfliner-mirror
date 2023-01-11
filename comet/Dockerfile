# renovate: datasource=docker depName=alpine
ARG ALPINE_VERSION=3.16
# renovate: datasource=docker depName=ruby versioning=ruby
ARG RUBY_VERSION=2.7.7

# see ../docker/base/Dockerfile
ARG BASE_IMAGE=registry.gitlab.com/surfliner/surfliner/base
# see ../docker/prod/Dockerfile
ARG PROD_IMAGE=registry.gitlab.com/surfliner/surfliner/prod

# these ARGs are used by the ONBUILD commands in the base image
ARG BUILD_TIME_APKS='build-base curl gcompat git nodejs postgresql-dev tzdata yarn'
ARG LOCAL_PROJECT=comet
FROM $BASE_IMAGE:latest as comet-base


FROM comet-base as ruby-build-prod
# used in ruby-bundle-cleanup.sh for locating the bundle cache
ENV RUBY_ABI=2.7.0

ARG LOCAL_PROJECT=comet
ARG DOCKER_ROOT=/home/${LOCAL_PROJECT}
# used in ruby-bundle-cleanup.sh
ENV DOCKER_PROJECT=${DOCKER_ROOT}/app

COPY scripts/docker/*.sh ${DOCKER_PROJECT}/
RUN ${DOCKER_PROJECT}/ruby-bundle-prod.sh
RUN ${DOCKER_PROJECT}/ruby-bundle-cleanup.sh

COPY $LOCAL_PROJECT $DOCKER_PROJECT

RUN \
  DATABASE_URL='postgresql://fake' \
  DB_ADAPTER=nulldb \
  RAILS_ENV=production \
  SECRET_KEY_BASE=`bin/rake secret` \
  bundle exec rake assets:precompile


# these ARGs are used by the ONBUILD commands in the base image
ARG LOCAL_PROJECT=comet
ARG RUN_TIME_APKS='curl libpq nodejs tini tzdata zip'
FROM $PROD_IMAGE:latest as comet-web-prod

COPY --from=ruby-build-prod --chown=$UID:$GID ${DOCKER_PROJECT}/public/assets ${DOCKER_PROJECT}/public/assets
COPY --from=ruby-build-prod --chown=$UID:$GID ${DOCKER_PROJECT}/public/uv ${DOCKER_PROJECT}/public/uv
COPY --from=ruby-build-prod --chown=$UID:$GID ${DOCKER_PROJECT}/vendor ${DOCKER_PROJECT}/vendor

RUN bundle config set deployment 'true'
RUN bundle config set without 'test development'
ENV BUNDLE_PATH="${DOCKER_PROJECT}/vendor/bundle"


FROM comet-web-prod as comet-worker-prod
# the directory of the host system from which application files are copied
ARG LOCAL_PROJECT=comet
# the project path on the image
ARG DOCKER_ROOT=/home/${LOCAL_PROJECT}
ARG DOCKER_PROJECT=${DOCKER_ROOT}/app
WORKDIR $DOCKER_PROJECT

USER root
RUN apk --no-cache add \
  bash \
  ffmpeg \
  mediainfo \
  openjdk11-jre \
  perl
USER app

# renovate: datasource=github-releases depName=harvard-lts/fits
ARG FITS_VERSION=1.5.5
RUN mkdir -p /app/fits && \
    cd /app/fits && \
    wget https://github.com/harvard-lts/fits/releases/download/${FITS_VERSION}/fits-${FITS_VERSION}.zip -O fits.zip && \
    unzip fits.zip && \
    rm fits.zip && \
    chmod a+x /app/fits/fits.sh
ENV PATH="${PATH}:/app/fits"
ENV MALLOC_ARENA_MAX=2

CMD ["bundle", "exec", "sidekiq"]

FROM comet-base as comet-test
ARG RUBY_ABI=2.7.0
ARG LOCAL_PROJECT=comet
ARG DOCKER_ROOT=/home/${LOCAL_PROJECT}
ARG DOCKER_PROJECT=${DOCKER_ROOT}/app

RUN bundle install --jobs "$(nproc)"

COPY scripts/docker/*.sh ${DOCKER_PROJECT}/
RUN ${DOCKER_PROJECT}/ruby-bundle-cleanup.sh

COPY $LOCAL_PROJECT $DOCKER_PROJECT
COPY scripts/* $DOCKER_PROJECT/scripts/
ENV PATH="${DOCKER_PROJECT}/scripts:${PATH}"

RUN RAILS_ENV=production SECRET_KEY_BASE=fakedevsecret DB_ADAPTER=nulldb RABBITMQ_ENABLED=false DATABASE_URL='postgresql://fake' bundle exec rake assets:precompile

ENV RAILS_ROOT=${DOCKER_PROJECT}
ENV RAILS_SERVE_STATIC_FILES=1
ENTRYPOINT ["bin/docker-entrypoint.sh"]

FROM comet-base as comet-dev
ARG LOCAL_PROJECT=comet
ARG DOCKER_ROOT=/home/${LOCAL_PROJECT}
ARG DOCKER_PROJECT=${DOCKER_ROOT}/app

# renovate: datasource=github-releases depName=harvard-lts/fits
ARG FITS_VERSION=1.5.5
RUN mkdir -p /app/fits && \
    cd /app/fits && \
    wget https://github.com/harvard-lts/fits/releases/download/${FITS_VERSION}/fits-${FITS_VERSION}.zip -O fits.zip && \
    unzip fits.zip && \
    rm fits.zip && \
    chmod a+x /app/fits/fits.sh
COPY scripts/* $DOCKER_PROJECT/scripts/
ENV PATH="${DOCKER_PROJECT}/scripts:${PATH}:/app/fits"

RUN apk --no-cache add \
  bash \
  ffmpeg \
  less \
  mediainfo \
  openjdk11-jre \
  perl \
  postgresql-client

RUN bundle install --jobs "$(nproc)"

COPY $LOCAL_PROJECT $DOCKER_PROJECT

RUN RAILS_ENV=production SECRET_KEY_BASE=fakedevsecret DB_ADAPTER=nulldb RABBITMQ_ENABLED=false DATABASE_URL='postgresql://fake' bundle exec rake assets:precompile
ENV RAILS_ROOT=${DOCKER_PROJECT}

ENTRYPOINT ["bin/docker-entrypoint.sh"]
