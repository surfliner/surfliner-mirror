# frozen_string_literal: true

require 'dry/transaction'
require 'sinatra'
require 'valkyrie'
require_relative '../lib/lark'

##
# Lark is an authority control platform.
module Lark
  Core.finalize! # load the application dependencies

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
      RecordController.new(params: params).show
    end

    post '/' do
      RecordController.new(request: request).create
    end

    put '/batch_edit' do
      RecordController.new(request: request).batch_update
    end

    put '/:id' do
      RecordController.new(request: request, params: params).update
    end
  end

  def application
    Application.new
  end
  module_function :application
end
