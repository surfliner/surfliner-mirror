# frozen_string_literal: true

if ENV.fetch('EVENT_ADAPTER', :sql).to_sym == :sql
  require 'sequel'
  require 'sequel/adapters/postgresql'
  require 'sequel/core'
  require 'sequel_pg'
  require_relative '../../config/database'
  require 'logger'

  namespace :db do
    desc 'Create Database ...'
    task :create do
      puts "Database connection info: #{DATABASE.inspect}"
      connection = Sequel.connect(DATABASE, logger: Logger.new($stderr))
      begin
        connection.execute "CREATE DATABASE #{DATABASE[:database]}"
        puts "Database #{DATABASE[:database]} is created."
      rescue Sequel::DatabaseError => e
        puts "Error creating database #{DATABASE[:database]}: #{e}"
      end
    end

    desc 'Run migrations ...'
    task :migrate, [:version] do |t, args|
      Sequel.extension :migration
      version = args[:version].to_i if args[:version] && t
      Sequel.connect(DATABASE, logger: Logger.new($stderr)) do |db|
        Sequel::Migrator.run(db, 'db/migrations', target: version)
      end
    rescue PG::ConnectionBad => e
      puts "Database connection failed on: #{DATABASE.inspect}"
      raise e
    end

    desc 'Drop Database ...'
    task :drop do
      new_connection = Sequel.connect(DATABASE, logger: Logger.new($stderr))
      new_connection.execute "DROP DATABASE IF EXISTS #{DATABASE[:database]}"
      puts "#{DATABASE[:database]} is dropped"
    end
  end
end
