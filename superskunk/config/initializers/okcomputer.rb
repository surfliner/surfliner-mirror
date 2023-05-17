# frozen_string_literal: true

# Mount the health endpoint at /healthz
# Review all health checks at /healthz/all
OkComputer.mount_at = "healthz"

OkComputer::Registry.deregister "database"

DATABASE_URL = "postgresql://#{ENV["POSTGRESQL_USERNAME"]}:#{ENV["POSTGRESQL_PASSWORD"]}@#{ENV["POSTGRESQL_HOST"]}:#{ENV["POSTGRESQL_PORT"]}/#{ENV["POSTGRESQL_DATABASE"]}"
OkComputer::Registry.register "sequel", OkComputer::SequelCheck.new(
  database: Sequel.connect(DATABASE_URL),
  migration_directory: "../db/sequel"
)
