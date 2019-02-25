FROM ruby:2.6.1-alpine as builder

RUN apk --no-cache upgrade && \
  apk add --no-cache \
  build-base \
  postgresql-dev \
  nodejs-current \
  yarn \
  libxml2-dev \
  libxslt-dev \
  sqlite-dev \
  tzdata

RUN mkdir -p /build-src
WORKDIR /build-src
COPY Gemfile* ./
RUN gem update bundler
RUN bundle install --jobs $(nproc) --retry 2

FROM ruby:2.6.1-alpine

RUN apk --no-cache upgrade && \
  apk add --no-cache \
  git \
  postgresql-dev \
  nodejs-current \
  sqlite-dev \
  yarn \
  tzdata

RUN addgroup -g 1000 -S starlight && \
    adduser -u 1000 -S starlight -G starlight
USER starlight

RUN mkdir -p /home/starlight/app
WORKDIR /home/starlight/app
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --chown=starlight:starlight . /home/starlight/app/
RUN yarn install
