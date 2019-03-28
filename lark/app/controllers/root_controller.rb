# frozen_string_literal: true

##
# A controller handling root-level API requests; i.e. requests on `/`
#
# This controller provides a service description of the API.
class RootController < ApplicationController
  ##
  # Show the API service description
  def show
    data = { version: '0.1.0' }

    [200, { 'Content-Type' => 'application/json' }, [data.to_json]]
  end
end
