FROM ruby:2.6-alpine

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
    postgresql-dev

RUN gem update bundler

RUN mkdir -p /home/lark/app
WORKDIR /home/lark/app

COPY lark/Gemfile* ./
COPY gems /home/lark/gems
RUN bundle check || bundle install --jobs "$(nproc)"

COPY lark .

CMD ["bin/lark.sh"]
