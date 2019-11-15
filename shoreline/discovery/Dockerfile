FROM ruby:2.6.2-alpine

RUN apk --no-cache upgrade && \
  apk add build-base \
  curl \
  git \
  yarn \
  postgresql postgresql-dev

RUN gem update bundler

RUN mkdir /data
WORKDIR /data
COPY Gemfile* ./
RUN bundle install --jobs "$(nproc)"
COPY . ./

CMD ["bundle", "exec", "puma", "-v", "--debug", "-b", "tcp://0.0.0.0:3000"]
ENTRYPOINT ["bin/docker-entrypoint.sh"]