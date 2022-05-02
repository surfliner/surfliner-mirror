#!/bin/sh

bundle config set deployment 'true'
bundle config set without 'test development'
bundle install --jobs "$(nproc)"
