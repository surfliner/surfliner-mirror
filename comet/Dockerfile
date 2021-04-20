ARG HYRAX_IMAGE_VERSION=comet
FROM registry.gitlab.com/surfliner/surfliner/hyrax-base:$HYRAX_IMAGE_VERSION as comet

ARG PROJECTPATH=comet

COPY --chown=1001:101 $PROJECTPATH/scripts/db-migrate-seed.sh /app/samvera/db-migrate-seed.sh
COPY --chown=1001:101 $PROJECTPATH/Gemfile* /app/samvera/hyrax-webapp/
RUN bundle install --jobs "$(nproc)"

COPY --chown=1001:101 $PROJECTPATH /app/samvera/hyrax-webapp
RUN RAILS_ENV=production SECRET_KEY_BASE=`bin/rake secret` DB_ADAPTER=nulldb DATABASE_URL='postgresql://fake' bundle exec rake assets:precompile

ENTRYPOINT ["/app/samvera/hyrax-webapp/scripts/entrypoint.sh"]
CMD ["bundle", "exec", "puma"]


# Comet worker image
FROM comet as comet-worker

ENV MALLOC_ARENA_MAX=2

USER root
RUN apk --no-cache add bash \
  ffmpeg \
  mediainfo \
  openjdk11-jre \
  perl
RUN bundle check || bundle install --jobs "$(nproc)"

USER app

RUN mkdir -p /app/fits && \
    cd /app/fits && \
    wget https://github.com/harvard-lts/fits/releases/download/1.5.0/fits-1.5.0.zip -O fits.zip && \
    unzip fits.zip && \
    rm fits.zip && \
    chmod a+x /app/fits/fits.sh
ENV PATH="${PATH}:/app/fits"

CMD bundle exec sidekiq
