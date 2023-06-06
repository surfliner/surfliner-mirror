# frozen_string_literal: true

require "rack/healthcheck"
require "sinatra"
require "valkyrie"
require "zeitwerk"
require_relative "../lib/lark"

##
# Lark is an authority control platform.
module Lark
  Zeitwerk::Loader.new.tap do |loader|
    root = Lark::Core.config.root
    loader.inflector.inflect "version" => "VERSION"
    loader.push_dir root.join("lib").realpath
    loader.push_dir root.join("app").realpath
    loader.push_dir root.join("app/controllers").realpath
    loader.push_dir root.join("app/controllers/concerns").realpath
    loader.push_dir root.join("app/models").realpath
    loader.push_dir root.join("app/transactions").realpath
  end.setup

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
    use Rack::Healthcheck::Middleware, "/healthz"

    set :root, File.expand_path("..", File.dirname(__FILE__))

    get "/" do
      ServiceDescriptionController.new(request: request).show
    end

    get "/search" do
      SearchController.new(params: params).exact_search
    end

    get "/:id" do
      RecordController.new(params: params).show
    end

    post "/batch_edit" do
      BatchController.new(request: request).batch_update
    end

    post "/batch_import" do
      BatchController.new(request: request).batch_import
    end

    post "/" do
      RecordController.new(request: request).create
    end

    put "/:id" do
      RecordController.new(request: request, params: params).update
    end

    options "/" do
      ServiceDescriptionController.new(params: params).options
    end

    options "/search" do
      SearchController.new(params: params).options
    end

    options "/batch_edit" do
      BatchController.new(params: params).options
    end

    options "/:id" do
      RecordController.new(params: params).options
    end
  end

  def application
    Application.new
  end
  module_function :application
end
