# renovate: datasource=docker depName=ruby versioning=ruby
ARG RUBY_VERSION=3.2.1
FROM ruby:$RUBY_VERSION-alpine as base

ARG PROJECTPATH=lark-ui
ARG DOCKERROOT=/home/${PROJECTPATH}
ENV PATH="$DOCKERROOT/scripts:$PATH"

RUN apk --no-cache add \
  curl \
  libxml2-dev \
  libxslt-dev \
  shared-mime-info \
  tzdata

WORKDIR ${DOCKERROOT}/app
COPY ${PROJECTPATH}/Gemfile* ${DOCKERROOT}/app/
COPY gems ${DOCKERROOT}/gems/

CMD ["bundle", "exec", "puma", "-v", "--debug", "-b", "tcp://0.0.0.0:3000"]
ENTRYPOINT ["bin/docker-entrypoint.sh"]


FROM base as development
ARG PROJECTPATH=lark-ui
ARG DOCKERROOT=/home/${PROJECTPATH}

RUN apk --no-cache add \
  build-base

RUN gem update bundler && \
      bundle config build.nokogiri --use-system-libraries && \
      bundle install --jobs "$(nproc)" --retry 2

COPY ${PROJECTPATH} ${DOCKERROOT}/app/
COPY scripts ${DOCKERROOT}/scripts/


FROM base as production
ARG PROJECTPATH=lark-ui
ARG DOCKERROOT=/home/${PROJECTPATH}

COPY ${PROJECTPATH} ${DOCKERROOT}/app/
COPY scripts ${DOCKERROOT}/scripts/
COPY --from=development /usr/local/bundle /usr/local/bundle

RUN bundle config set without 'development test' \
    && bundle clean --force \
    # Remove unneeded files (cached *.gem, *.o, *.c)
    && find /usr/local/bundle/ -name "*.gem" -delete \
    && find /usr/local/bundle/ -name "*.c" -delete \
    && find /usr/local/bundle/ -name "*.o" -delete

RUN rm -rf node_modules tmp/* log/* vendor/dictionary*
