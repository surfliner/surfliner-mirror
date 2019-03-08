FROM ruby:2.6-alpine

RUN apk update && \
    apk add build-base libc-dev libxml2 libxml2-dev libxslt libxslt-dev \
    postgresql postgresql-dev

RUN mkdir /data
RUN mkdir /config
WORKDIR /data
COPY Gemfile* ./
ENV BUNDLE_JOBS=4
RUN gem update bundler
RUN bundle install
COPY . ./
