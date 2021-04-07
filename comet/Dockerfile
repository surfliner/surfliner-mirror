ARG HYRAX_IMAGE_VERSION=comet
FROM registry.gitlab.com/surfliner/surfliner/hyrax-base:$HYRAX_IMAGE_VERSION

ARG PROJECTPATH=comet

COPY --chown=1001:101 $PROJECTPATH/Gemfile /app/samvera/hyrax-webapp
COPY --chown=1001:101 $PROJECTPATH/Gemfile.lock /app/samvera/hyrax-webapp
RUN bundle install --jobs "$(nproc)"

COPY --chown=1001:101 $PROJECTPATH /app/samvera/hyrax-webapp
RUN RAILS_ENV=production SECRET_KEY_BASE=`bin/rake secret` DB_ADAPTER=nulldb DATABASE_URL='postgresql://fake' bundle exec rake assets:precompile
