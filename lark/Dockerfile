# renovate: datasource=docker depName=ruby versioning=ruby
ARG RUBY_VERSION=2.7.4
FROM ruby:$RUBY_VERSION-alpine as lark

ARG PROJECTPATH=lark
ARG DOCKERROOT=/home/${PROJECTPATH}

RUN apk update && apk add \
    build-base \
    curl \
    git \
    libc-dev \
    libxml2 \
    libxml2-dev \
    libxslt \
    libxslt-dev \
    postgresql \
    postgresql-dev \
    zip

RUN gem update bundler

WORKDIR ${DOCKERROOT}/app

COPY ${PROJECTPATH}/Gemfile* ${DOCKERROOT}/app/
COPY gems ${DOCKERROOT}/gems/
RUN bundle check || bundle install --jobs "$(nproc)"

COPY ${PROJECTPATH} ${DOCKERROOT}/app/
COPY scripts ${DOCKERROOT}/scripts/
ENV PATH="$DOCKERROOT/scripts:$PATH"

CMD ["bin/lark.sh"]
