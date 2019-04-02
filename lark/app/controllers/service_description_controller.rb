# frozen_string_literal: true

require_relative 'application_controller'

##
# This controller provides a service description of the API.
class ServiceDescriptionController < ApplicationController
  ##
  # Show the API service description
  def show
    service_description = ServiceDescription.new

    [200, response_headers, [service_description.to_json]]
  end
end
