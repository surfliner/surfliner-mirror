# renovate: datasource=docker depName=alpine
ARG ALPINE_VERSION=3.16
# renovate: datasource=docker depName=ruby versioning=ruby
ARG RUBY_VERSION=2.7.6

FROM ruby:$RUBY_VERSION-alpine$ALPINE_VERSION as prod
# set these at build-time with --build-arg
ONBUILD ARG LOCAL_PROJECT
ONBUILD ARG RUN_TIME_APKS

ONBUILD ARG GID=10001
ONBUILD ARG UID=10000

ONBUILD ARG DOCKER_ROOT=/home/${LOCAL_PROJECT}
ONBUILD ARG DOCKER_PROJECT=${DOCKER_ROOT}/app
ONBUILD WORKDIR ${DOCKER_PROJECT}

# run-time dependencies only
ONBUILD RUN apk --no-cache add $RUN_TIME_APKS

ONBUILD RUN addgroup -S --gid $GID app && \
  adduser -S -G app -u $UID -s /bin/sh -h /app app
ONBUILD USER app

ONBUILD COPY --chown=$UID:$GID gems ${DOCKER_ROOT}/gems/
ONBUILD COPY --chown=$UID:$GID $LOCAL_PROJECT $DOCKER_PROJECT
ONBUILD COPY --chown=$UID:$GID scripts/* $DOCKER_PROJECT/scripts/
ONBUILD ENV PATH="${DOCKER_PROJECT}/scripts:${PATH}"

# TODO: should these be set by helm/docker-compose?
ONBUILD ENV RAILS_ROOT=${DOCKER_PROJECT}
ONBUILD ENV RAILS_SERVE_STATIC_FILES=1
ONBUILD ENTRYPOINT ["tini", "--", "bin/docker-entrypoint.sh"]
ONBUILD CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:3000"]
