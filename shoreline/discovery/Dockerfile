FROM ruby:2.6.2-alpine

RUN apk --no-cache upgrade && apk add \
  build-base \
  curl \
  git \
  postgresql \
  postgresql-dev \
  yarn

RUN gem update bundler

RUN mkdir -p /home/shoreline/discovery/app
WORKDIR /home/shoreline/discovery/app

COPY shoreline/discovery/Gemfile* ./
COPY gems ../../gems/
RUN bundle check || bundle install --jobs "$(nproc)"

COPY shoreline/discovery .

RUN bundle exec rake assets:precompile

CMD ["bundle", "exec", "puma", "-v", "--debug", "-b", "tcp://0.0.0.0:3000"]
ENTRYPOINT ["bin/docker-entrypoint.sh"]
