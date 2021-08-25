# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

require "bundler"

Bundler.require

require_relative "config/environment"

run Lark.application
