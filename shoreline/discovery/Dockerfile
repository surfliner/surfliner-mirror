FROM ruby:2.6.2-alpine as base
ARG PROJECTPATH=shoreline
ARG DOCKERROOT=/home/${PROJECTPATH}
ENV PATH="$DOCKERROOT/scripts:$PATH"

RUN apk --no-cache upgrade && apk add \
      curl \
      libxml2-dev \
      libxslt-dev \
      nodejs \
      postgresql-dev

WORKDIR ${DOCKERROOT}/discovery/app
COPY ${PROJECTPATH}/discovery/Gemfile* ${DOCKERROOT}/discovery/app/
COPY gems ${DOCKERROOT}/gems/

FROM base as development
ARG PROJECTPATH=shoreline
ARG DOCKERROOT=/home/${PROJECTPATH}

RUN apk --no-cache upgrade && apk add \
  build-base \
  postgresql \
  yarn

RUN gem update bundler && \
      bundle config build.nokogiri --use-system-libraries && \
      bundle install --jobs "$(nproc)" --retry 2

COPY ${PROJECTPATH}/discovery ${DOCKERROOT}/discovery/app/
COPY scripts ${DOCKERROOT}/scripts/

RUN bundle exec rake assets:precompile

CMD ["bundle", "exec", "puma", "-v", "--debug", "-b", "tcp://0.0.0.0:3000"]
ENTRYPOINT ["bin/docker-entrypoint.sh"]

FROM base as production
ARG PROJECTPATH=shoreline
ARG DOCKERROOT=/home/${PROJECTPATH}

COPY ${PROJECTPATH}/discovery ${DOCKERROOT}/discovery/app/
COPY scripts ${DOCKERROOT}/scripts/
COPY --from=development /usr/local/bundle /usr/local/bundle

# set env vars to allow assets to compile
ENV APP_URL=http://localhost
ENV CONTACT_EMAIL=contact@example.com
ENV DATABASE_ADAPTER=postgresql
ENV DELIVERY_METHOD=letter_opener_web
ENV GEOSERVER_HOST=geoserver
ENV GEOSERVER_PASSWORD=password
ENV GEOSERVER_PORT=80
ENV GEOSERVER_USER=geo-admin
ENV POSTGRES_DB=shoreline
ENV POSTGRES_HOST=postgres
ENV POSTGRES_PASSWORD=password
ENV POSTGRES_USER=user
ENV SECRET_KEY_BASE=secret12345
ENV SOLR_CORE_NAME=collection1
ENV SOLR_HOST=solr
ENV SOLR_PORT=8983

RUN bundle config set without 'development test' \
    && bundle clean --force \
    # Remove unneeded files (cached *.gem, *.o, *.c)
    && find /usr/local/bundle/ -name "*.gem" -delete \
    && find /usr/local/bundle/ -name "*.c" -delete \
    && find /usr/local/bundle/ -name "*.o" -delete

RUN apk add --no-cache yarn && \
    RAILS_ENV=production bundle exec rake assets:precompile && \
    apk del yarn

RUN rm -rf node_modules tmp/* log/* vendor/dictionary*

CMD ["bundle", "exec", "puma", "-v", "--debug", "-b", "tcp://0.0.0.0:3000"]
ENTRYPOINT ["bin/docker-entrypoint.sh"]
