FROM ruby:2.6.2-alpine

RUN apk --no-cache upgrade && \
  apk add build-base \
  git \
  yarn \
  sqlite-dev

RUN gem update bundler

RUN mkdir /data
WORKDIR /data
COPY Gemfile* ./
ENV BUNDLE_JOBS=4
RUN bundle install
COPY . ./

CMD ["bundle", "exec", "rails", "server"]