# frozen_string_literal: true

require_relative "bulkrax_work_create"
require_relative "steps/add_bulkrax_files"

module Hyrax
  module Transactions
    class CometContainer < Container
      namespace "change_set" do |ops| # Hyrax::ChangeSet
        ops.register "bulkrax_create_work" do
          BulkraxWorkCreate.new
        end
      end

      namespace "work_resource" do |ops| # Hyrax::Work resource
        ops.register "add_bulkrax_files" do
          Steps::AddBulkraxFiles.new
        end
      end
    end
  end
end
