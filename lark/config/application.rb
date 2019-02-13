require 'sinatra'
require 'valkyrie'

# TODO: fix these up later with https://dry-rb.org/gems/dry-system/
require_relative '../lib/lark'
require_relative '../app/controllers/record_controller'
require_relative '../app/models/concept'

##
# Lark is an authority control platform.
module Lark
  ##
  # The Lark application is a basic Rack application implementing the Lark API.
  # It uses `Sinatra` to provide simple routing.
  #
  # @note as this application develops, we may want to consider just using
  #   Rails. Let's see if it stays simple.
  #
  # @see http://sinatrarb.com/intro.html
  # @see https://rack.github.io/
  class Application < Sinatra::Base
    get '/:id' do
      RecordController.new(params).call
    end
  end

  def application
    Application.new
  end
  module_function :application
end
