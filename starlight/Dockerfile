FROM ruby:2.6.6-alpine as starlight

ARG PROJECTPATH=starlight
ARG DOCKERROOT=/home/${PROJECTPATH}

RUN apk --no-cache upgrade && \
  apk add --no-cache \
  build-base \
  curl \
  git \
  imagemagick \
  less \
  libxml2-dev \
  libxslt-dev \
  nodejs-current \
  postgresql-dev \
  sqlite-dev \
  tzdata \
  yarn

RUN gem update bundler

WORKDIR ${DOCKERROOT}/app

COPY ${PROJECTPATH}/Gemfile* ${DOCKERROOT}/app/
COPY gems ${DOCKERROOT}/gems/
RUN bundle check || bundle install --jobs "$(nproc)"

COPY ${PROJECTPATH} ${DOCKERROOT}/app/
COPY scripts ${DOCKERROOT}/scripts/
COPY .styles $DOCKERROOT/.styles/
ENV PATH="$DOCKERROOT/scripts:$PATH"

RUN bundle exec rake assets:precompile

CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:3000"]
ENTRYPOINT ["/bin/sh", "bin/docker-entrypoint.sh"]
