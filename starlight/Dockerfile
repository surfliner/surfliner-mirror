FROM ruby:2.5.3
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update -qq && \
    apt-get install -qq -y --no-install-recommends \
    build-essential \
    nodejs \
    libpq-dev \
    git \
    tzdata \
    libxml2-dev \
    libxslt-dev \
    ssh \
    yarn \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /data
WORKDIR /data
COPY Gemfile* ./
ENV BUNDLE_JOBS=4
RUN gem update bundler
RUN bundle install
COPY . ./

RUN yarn install

CMD ["rails", "server"]
