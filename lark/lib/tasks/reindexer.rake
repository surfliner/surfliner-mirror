# frozen_string_literal: true

require "dotenv/tasks" unless ENV["RACK_ENV"] == "production"

require "valkyrie"
require_relative "../../config/environment"
require "bundler"

Bundler.require

desc "Re-index all authority records"
task :reindex_all do
  puts "Re-indexing all authority records ..."
  reindexer = Lark::Reindexer.new
  begin
    ids = reindexer.reindex_all
    puts "Re-indexing done!\nRecords processed:\n#{ids}"
  rescue => e
    puts "Error: #{e}"
  end
end

desc "Re-index a single authority record with :id"
task :reindex, [:id] do |_t, args|
  puts "Re-index authority record with ID #{args[:id]} ..."
  reindexer = Lark::Reindexer.new
  begin
    reindexer.reindex_record id: args[:id]
  rescue => e
    puts "Error re-index #{args[:id]}: #{e}"
  end
end
