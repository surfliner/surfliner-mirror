# frozen_string_literal: true

require "dry/monads"

module Transactions
  module Steps
    class AddBulkraxFiles
      include Dry::Monads[:result]

      ##
      # @param [Class] handler
      def initialize(handler: Hyrax::WorkUploadsHandler)
        @handler = handler
      end

      ##
      # @param [Hyrax::Work] obj
      # @param [Hash<Symbol, Array<Fog::AWS::Storage::File>>] files
      # @param [User] user
      #
      # @return [Dry::Monads::Result]
      def call(obj, files:, user:)
        if files && user

          # The current assumption, until a more comprehensive approach is agreed upon, is to
          # create a NEW FileSet for each bulkrax ingest, assigning ALL files for a given object/CSVEntry to that
          # FileSet.
          # see: https://gitlab.com/surfliner/surfliner/-/issues/1317
          file_set_timestamp = Hyrax::TimeService.time_in_utc
          file_set = FileIngest.make_fileset_for(
            filename: String(file_set_timestamp),
            last_modified: file_set_timestamp,
            permissions: Hyrax::AccessControlList.new(resource: obj),
            user: user,
            work: obj
          )

          begin
            files.each do |use, file|
              file.each do |f|
                FileIngest.upload(
                  content_type: f.content_type,
                  file_body: StringIO.new(f.body),
                  filename: Pathname.new(f.key).basename,
                  last_modified: f.last_modified,
                  permissions: Hyrax::AccessControlList.new(resource: obj),
                  size: f.content_length,
                  user: user,
                  work: obj,
                  use: use,
                  file_set: file_set
                )
              end
            end
          rescue => e
            Hyrax.logger.error(e)
            return Failure[:failed_to_attach_file_sets, files]
          end
        end

        Success(obj)
      end
    end
  end
end
