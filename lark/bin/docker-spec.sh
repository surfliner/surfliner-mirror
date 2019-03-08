#!/bin/sh
# Run complete rspec test suite
compose_env="./docker/test/"
docker-compose -f "${compose_env}docker-compose.yml" exec web bundle exec rspec
