# renovate: datasource=docker depName=ruby versioning=ruby
ARG RUBY_VERSION=3.1.2
FROM ruby:$RUBY_VERSION-alpine as surfliner_schema

RUN apk add --no-cache \
  build-base \
  curl \
  gcompat \
  git \
  less \
  yarn \
  zip

RUN gem update bundler

WORKDIR /app

COPY Gemfile* /app/
COPY ./surfliner_schema.gemspec /app/
COPY ./lib/surfliner_schema/version.rb /app/lib/surfliner_schema/version.rb
RUN bundle check || bundle install --jobs "$(nproc)"

COPY . /app

CMD ["rspec"]
ENTRYPOINT ["/bin/sh", "-c"]

