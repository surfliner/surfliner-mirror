# frozen_string_literal: true

##
# This controller provides a service description of the API.
class ServiceDescriptionController < ApplicationController
  ##
  # Show the API service description
  def show
    data = { version: '0.1.0' }

    [200, response_headers, [data.to_json]]
  end
end
