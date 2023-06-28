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
                  use: use
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
