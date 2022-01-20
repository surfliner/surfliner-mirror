# renovate: datasource=docker depName=ruby versioning=ruby
ARG RUBY_VERSION=2.7.4
FROM ruby:$RUBY_VERSION-alpine as tidewater

ARG PROJECTPATH=tidewater
ARG DOCKERROOT=/home/${PROJECTPATH}

RUN apk --no-cache upgrade && \
  apk add --no-cache \
  build-base \
  curl \
  git \
  less \
  nodejs-current \
  postgresql-dev \
  shared-mime-info \
  tzdata \
  yarn \
  zip

RUN gem update bundler

WORKDIR ${DOCKERROOT}/app

COPY ${PROJECTPATH}/Gemfile* ${DOCKERROOT}/app/
COPY gems ${DOCKERROOT}/gems/
RUN bundle check || bundle install --jobs "$(nproc)"

COPY ${PROJECTPATH} ${DOCKERROOT}/app/
COPY scripts ${DOCKERROOT}/scripts/
COPY .styles $DOCKERROOT/.styles/
ENV PATH="$DOCKERROOT/scripts:$PATH"

CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:3000"]
ENTRYPOINT ["/bin/sh", "bin/docker-entrypoint.sh"]
