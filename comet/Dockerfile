# renovate: datasource=docker depName=alpine
ARG ALPINE_VERSION=3.15
# renovate: datasource=docker depName=ruby versioning=ruby
ARG RUBY_VERSION=2.7.5

FROM ruby:$RUBY_VERSION-alpine$ALPINE_VERSION as base
# the directory of the host system from which application files are copied
ARG LOCAL_PROJECT=comet
# the project path on the image
ARG DOCKER_ROOT=/app/samvera
ARG DOCKER_PROJECT=${DOCKER_ROOT}/hyrax-webapp
WORKDIR $DOCKER_PROJECT

# build-time dependencies only
RUN apk --no-cache upgrade && \
  apk --no-cache add \
  build-base \
  gcompat \
  git \
  nodejs \
  postgresql-dev \
  tzdata \
  yarn

COPY ${LOCAL_PROJECT}/Gemfile* ${DOCKER_PROJECT}/
COPY gems ${DOCKER_ROOT}/gems/

FROM base as ruby-build-prod
# used in ruby-bundle-cleanup.sh for locating the bundle cache
ENV RUBY_ABI=2.7.0

ARG LOCAL_PROJECT=comet
ARG DOCKER_ROOT=/app/samvera
# used in ruby-bundle-cleanup.sh
ENV DOCKER_PROJECT=${DOCKER_ROOT}/hyrax-webapp

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

FROM ruby:$RUBY_VERSION-alpine$ALPINE_VERSION as comet-web-prod
ARG GID=10001
ARG UID=10000

ARG LOCAL_PROJECT=comet
ARG DOCKER_ROOT=/app/samvera
ARG DOCKER_PROJECT=${DOCKER_ROOT}/hyrax-webapp
WORKDIR $DOCKER_PROJECT

# run-time dependencies only
RUN apk --no-cache upgrade && \
  apk --no-cache add \
  curl \
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

COPY --from=ruby-build-prod --chown=$UID:$GID ${DOCKER_PROJECT}/public/assets ${DOCKER_PROJECT}/public/assets
COPY --from=ruby-build-prod --chown=$UID:$GID ${DOCKER_PROJECT}/public/uv ${DOCKER_PROJECT}/public/uv
COPY --from=ruby-build-prod --chown=$UID:$GID ${DOCKER_PROJECT}/vendor ${DOCKER_PROJECT}/vendor

RUN bundle config set deployment 'true'
RUN bundle config set without 'test development'
ENV BUNDLE_PATH="${DOCKER_PROJECT}/vendor/bundle"

# TODO: should these be set by helm/docker-compose?
ENV RAILS_ROOT=${DOCKER_PROJECT}
ENV RAILS_SERVE_STATIC_FILES=1
ENTRYPOINT ["tini", "--", "/app/samvera/hyrax-webapp/scripts/entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-v", "-b", "tcp://0.0.0.0:3000"]

FROM comet-web-prod as comet-worker-prod
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
ARG FITS_VERSION=1.5.4
RUN mkdir -p /app/fits && \
    cd /app/fits && \
    wget https://github.com/harvard-lts/fits/releases/download/${FITS_VERSION}/fits-${FITS_VERSION}.zip -O fits.zip && \
    unzip fits.zip && \
    rm fits.zip && \
    chmod a+x /app/fits/fits.sh
ENV PATH="${PATH}:/app/fits"
ENV MALLOC_ARENA_MAX=2

CMD ["bundle", "exec", "sidekiq"]

FROM base as comet-test
ARG RUBY_ABI=2.7.0
ARG LOCAL_PROJECT=comet
ARG DOCKER_ROOT=/app/samvera
ARG DOCKER_PROJECT=${DOCKER_ROOT}/hyrax-webapp

RUN bundle install --jobs "$(nproc)"

COPY scripts/docker/*.sh ${DOCKER_PROJECT}/
RUN ${DOCKER_PROJECT}/ruby-bundle-cleanup.sh

COPY gems ${DOCKER_ROOT}/gems/
COPY $LOCAL_PROJECT $DOCKER_PROJECT
COPY scripts/* $DOCKER_PROJECT/scripts/
ENV PATH="${DOCKER_PROJECT}/scripts:${PATH}"

ENV RAILS_ROOT=${DOCKER_PROJECT}
ENV RAILS_SERVE_STATIC_FILES=1
ENTRYPOINT ["/app/samvera/hyrax-webapp/scripts/entrypoint.sh"]

FROM base as comet-dev
ARG LOCAL_PROJECT=comet
ARG DOCKER_ROOT=/app/samvera
ARG DOCKER_PROJECT=${DOCKER_ROOT}/hyrax-webapp

# renovate: datasource=github-releases depName=harvard-lts/fits
ARG FITS_VERSION=1.5.4
RUN mkdir -p /app/fits && \
    cd /app/fits && \
    wget https://github.com/harvard-lts/fits/releases/download/${FITS_VERSION}/fits-${FITS_VERSION}.zip -O fits.zip && \
    unzip fits.zip && \
    rm fits.zip && \
    chmod a+x /app/fits/fits.sh
ENV PATH="${PATH}:/app/fits"

RUN apk --no-cache upgrade && \
  apk --no-cache add \
  bash \
  ffmpeg \
  less \
  mediainfo \
  openjdk11-jre \
  perl \
  postgresql-client

RUN bundle install --jobs "$(nproc)"

COPY $LOCAL_PROJECT $DOCKER_PROJECT

RUN RAILS_ENV=production SECRET_KEY_BASE=fakedevsecret DB_ADAPTER=nulldb DATABASE_URL='postgresql://fake' bundle exec rake assets:precompile

ENV RAILS_ROOT=${DOCKER_PROJECT}
ENTRYPOINT ["/app/samvera/hyrax-webapp/scripts/entrypoint.sh"]
