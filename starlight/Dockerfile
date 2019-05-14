FROM ruby:2.6.2-alpine

RUN uname -a
RUN echo 'http://mirror.leaseweb.com/alpine/latest-stable/main' > /etc/apk/repositories; \
    echo 'http://mirror.leaseweb.com/alpine/latest-stable/community' >> /etc/apk/repositories
RUN cat /etc/apk/repositories

RUN apk --no-cache upgrade && \
  apk add --no-cache \
  build-base \
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

RUN addgroup -g 1000 -S starlight && \
    adduser -u 1000 -S starlight -G starlight
USER starlight

RUN gem update bundler

RUN mkdir -p /home/starlight/app
WORKDIR /home/starlight/app
COPY --chown=starlight:starlight Gemfile* ./
RUN bundle check || bundle install --jobs "$(nproc)"
COPY --chown=starlight:starlight . ./
RUN yarn install --verbose

ENTRYPOINT ["/bin/sh", "/home/starlight/app/docker/docker-entrypoint.sh"]
