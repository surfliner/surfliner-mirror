FROM ruby:2.5.3
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get update -qq && \
    apt-get install -qq -y --no-install-recommends \
    build-essential \
    nodejs \
    libpq-dev \
    git \
    tzdata \
    libxml2-dev \
    libxslt-dev \
    ssh \
    libsqlite3-dev \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /data
WORKDIR /data
ADD . /data
ENV BUNDLE_JOBS=4
RUN bundle install
RUN bundle exec rake db:migrate
EXPOSE 3000