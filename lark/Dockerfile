FROM ruby:2.6-alpine

RUN apk update && \
    apk add build-base libc-dev libxml2 libxml2-dev libxslt libxslt-dev \
    postgresql postgresql-dev

RUN gem update bundler

RUN mkdir /data
RUN mkdir /config
WORKDIR /data
COPY Gemfile* ./
ENV BUNDLE_JOBS=4
RUN bundle install
COPY . ./

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "5000"]