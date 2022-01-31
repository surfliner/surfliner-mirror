# renovate: datasource=docker depName=ruby versioning=ruby
ARG RUBY_VERSION=3.0.3
FROM ruby:$RUBY_VERSION-alpine as superskunk

ARG PROJECTPATH=superskunk
ARG DOCKERROOT=/home/${PROJECTPATH}

RUN apk --no-cache upgrade && \
  apk add --no-cache \
  build-base \
  git \
  tzdata

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
ENTRYPOINT ["rails-entrypoint.sh"]