FROM ruby:2.6.6-alpine

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

RUN mkdir -p /home/starlight/app
WORKDIR /home/starlight/app

COPY starlight/Gemfile* ./
COPY gems /home/starlight/gems
RUN bundle check || bundle install --jobs "$(nproc)"

COPY starlight .

RUN bundle exec rake assets:precompile

CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:3000"]
ENTRYPOINT ["/bin/sh", "bin/docker-entrypoint.sh"]
