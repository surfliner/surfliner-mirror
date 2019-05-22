# frozen_string_literal: true

DATABASE = {
  user: ENV.fetch('POSTGRES_USER'),
  password: ENV.fetch('POSTGRES_PASSWORD'),
  host: ENV.fetch('POSTGRES_HOST'),
  port: ENV.fetch('POSTGRES_PORT'),
  database: ENV.fetch('POSTGRES_DB'),
  adapter: 'postgres'
}.freeze
