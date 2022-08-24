# renovate: datasource=docker depName=alpine
ARG ALPINE_VERSION=3.16
# renovate: datasource=docker depName=ruby versioning=ruby
ARG RUBY_VERSION=2.7.6
FROM ruby:$RUBY_VERSION-alpine$ALPINE_VERSION as base
# set these at build-time with --build-arg
ONBUILD ARG LOCAL_PROJECT
ONBUILD ARG BUILD_TIME_APKS

ONBUILD ARG DOCKER_ROOT=/home/${LOCAL_PROJECT}
# the project path on the image
ONBUILD ARG DOCKER_PROJECT=${DOCKER_ROOT}/app
ONBUILD WORKDIR ${DOCKER_PROJECT}

# build-time dependencies only
ONBUILD RUN apk --no-cache add $BUILD_TIME_APKS

ONBUILD COPY ${LOCAL_PROJECT}/Gemfile* ${DOCKER_PROJECT}/
ONBUILD COPY gems ${DOCKER_ROOT}/gems/
