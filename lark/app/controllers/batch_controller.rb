# frozen_string_literal: true

require 'csv'
require_relative 'application_controller'
require_relative 'concerns/record_controller_behavior'

##
# A controller that resolves requests for handling batch of authority records.
class BatchController < ApplicationController
  include RecordControllerBehavior

  ##
  # options for CORS preflight request
  # Access-Control-Allow-Methods: POST, OPTIONS.
  # Access-Control-Allow-Headers: Content-Type
  # Access-Control-Max-Age: 86400 (delta seconds, 24 hours)
  def options
    response_headers = {
      'Access-Control-Allow-Methods' => 'POST, OPTIONS',
      'Access-Control-Allow-Headers' => 'Content-Type',
      'Access-Control-Max-Age' => '86400'
    }

    [204, response_headers.merge(cors_allow_header), []]
  end

  ##
  # Update an existing authority record from the request
  def batch_update
    with_error_handling do
      authorities = parsed_body(format: ctype)
      authorities.each do |attrs|
        Lark::Transactions::UpdateAuthority
          .new(event_stream: event_stream, adapter: adapter)
          .call(id: attrs[:id],
                attributes: attrs)
      end

      [204, cors_allow_header, []]
    end
  end

  ##
  # Import authority records from CSV file
  def batch_import
    with_error_handling do
      path = '/tmp/lark_import.csv'
      copy_csv_file(path, request)
      CSV.foreach(path, headers: true, encoding: 'ISO-8859-1') do |row|
        create_record(row.to_hash.to_json)
      end
      File.delete(path) if File.exist?(path)
      [201, response_headers, []]
    end
  end

  private

  def create_record(data)
    Lark::Transactions::CreateAuthority
      .new(event_stream: event_stream)
      .call(attributes: parsed_csv(format: ctype, data: data))
      .value!
  end

  def copy_csv_file(path, request)
    data = request.body.read
    raise Lark::BadRequest if data.empty?

    file = File.open(path, 'wb')
    file.puts(data)
    file.close
  end
end
