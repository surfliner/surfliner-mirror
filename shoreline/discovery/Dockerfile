FROM ruby:2.6.2-alpine as shoreline

ARG PROJECTPATH=shoreline
ARG DOCKERROOT=/home/${PROJECTPATH}

RUN apk --no-cache upgrade && apk add \
  build-base \
  curl \
  git \
  postgresql \
  postgresql-dev \
  yarn

RUN gem update bundler

WORKDIR ${DOCKERROOT}/discovery/app

COPY ${PROJECTPATH}/discovery/Gemfile* ${DOCKERROOT}/discovery/app/
COPY gems ${DOCKERROOT}/gems/
RUN bundle check || bundle install --jobs "$(nproc)"

COPY ${PROJECTPATH}/discovery ${DOCKERROOT}/discovery/app/
COPY scripts ${DOCKERROOT}/scripts/
ENV PATH="$DOCKERROOT/scripts:$PATH"

RUN bundle exec rake assets:precompile

CMD ["bundle", "exec", "puma", "-v", "--debug", "-b", "tcp://0.0.0.0:3000"]
ENTRYPOINT ["bin/docker-entrypoint.sh"]
