# frozen_string_literal: true

DATABASE = {
  user: ENV.fetch("POSTGRESQL_USERNAME"),
  password: ENV.fetch("POSTGRESQL_PASSWORD"),
  host: ENV.fetch("POSTGRESQL_HOST"),
  port: ENV.fetch("POSTGRESQL_PORT"),
  database: ENV.fetch("POSTGRESQL_DATABASE"),
  adapter: "postgres"
}.freeze

DATABASE_AS_ADMIN = {
  user: "postgres",
  password: ENV.fetch("POSTGRESQL_POSTGRES_PASSWORD"),
  host: ENV.fetch("POSTGRESQL_HOST"),
  port: ENV.fetch("POSTGRESQL_PORT"),
  database: ENV.fetch("POSTGRESQL_DATABASE"),
  adapter: "postgres"
}.freeze
