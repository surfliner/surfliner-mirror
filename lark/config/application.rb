require 'sinatra'

module Lark
  ##
  # The Lark application is a basic Rack application implementing the Lark API.
  # It uses `Sinatra` to provide simple routing.
  #
  # @note as this application develops, we may want to consider just using Rails. Let's see if it stays simple.
  #
  # @see http://sinatrarb.com/intro.html
  # @see https://rack.github.io/
  class Application < Sinatra::Base
    get '/:id' do
      [404, {}, ['']]
    end
  end

  def application
    Application.new
  end
  module_function :application
end
