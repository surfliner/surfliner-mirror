# frozen_string_literal: true

DATABASE = {
  user: ENV['POSTGRES_USER'] || 'postgres',
  password: ENV['POSTGRES_PASSWORD'] || '',
  host: ENV['POSTGRES_HOST'] || 'localhost',
  port: ENV['POSTGRES_PORT'] || '5432',
  database: ENV['POSTGRES_DB'] || 'postgres',
  adapter: 'postgres'
}.freeze
