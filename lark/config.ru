# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

use Rack::Healthcheck::Middleware, '/health'

run Lark.application
