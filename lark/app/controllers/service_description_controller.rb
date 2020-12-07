# frozen_string_literal: true

##
# This controller provides a service description of the API.
class ServiceDescriptionController < ApplicationController
  ##
  # Show the API service description
  def show
    service_description = ServiceDescription.new

    [200, response_headers, [service_description.to_json]]
  end

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
end
