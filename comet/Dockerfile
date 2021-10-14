ARG HYRAX_IMAGE_VERSION=3.0.2
FROM ghcr.io/samvera/hyrax/hyrax-base:$HYRAX_IMAGE_VERSION as build-base

USER root
RUN apk --no-cache add \
  git \
  less \
  postgresql-client
USER app

FROM ghcr.io/samvera/hyrax/hyrax-base:$HYRAX_IMAGE_VERSION as ruby-base
ARG PROJECTPATH=comet
ARG DOCKERROOT=/app/samvera

USER app

COPY --chown=1001:101 $PROJECTPATH/Gemfile* $DOCKERROOT/hyrax-webapp/
COPY --chown=1001:101 gems ${DOCKERROOT}/gems/

RUN bundle check || bundle install --jobs "$(nproc)"

COPY --chown=1001:101 $PROJECTPATH/scripts/db-migrate-seed.sh $DOCKERROOT/db-migrate-seed.sh
COPY --chown=1001:101 $PROJECTPATH $DOCKERROOT/hyrax-webapp
COPY --chown=1001:101 scripts ${DOCKERROOT}/scripts/

RUN RAILS_ENV=production SECRET_KEY_BASE=`bin/rake secret` DB_ADAPTER=nulldb DATABASE_URL='postgresql://fake' bundle exec rake assets:precompile

#
# Comet Rails server
FROM build-base as comet
ARG PROJECTPATH=comet
ARG DOCKERROOT=/app/samvera

COPY --from=ruby-base --chown=1001:101 /usr/local/bundle/ /usr/local/bundle/
COPY --from=ruby-base --chown=1001:101 ${DOCKERROOT} ${DOCKERROOT}

ENTRYPOINT ["/app/samvera/hyrax-webapp/scripts/entrypoint.sh"]
CMD ["bundle", "exec", "puma"]

#
# Comet Sidekiq worker
FROM build-base as comet-worker
ARG PROJECTPATH=comet
ARG DOCKERROOT=/app/samvera

ENV MALLOC_ARENA_MAX=2

USER root
RUN apk --no-cache add bash \
  ffmpeg \
  mediainfo \
  openjdk11-jre \
  perl
USER app

RUN mkdir -p /app/fits && \
    cd /app/fits && \
    wget https://github.com/harvard-lts/fits/releases/download/1.5.0/fits-1.5.0.zip -O fits.zip && \
    unzip fits.zip && \
    rm fits.zip && \
    chmod a+x /app/fits/fits.sh
ENV PATH="${PATH}:/app/fits"

COPY --from=ruby-base --chown=1001:101 /usr/local/bundle/ /usr/local/bundle/
COPY --from=ruby-base --chown=1001:101 ${DOCKERROOT} ${DOCKERROOT}

ENTRYPOINT ["/app/samvera/hyrax-webapp/scripts/entrypoint.sh"]
CMD bundle exec sidekiq
