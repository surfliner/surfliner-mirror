# frozen_string_literal: true

require "spec_helper"

ENV["RAILS_ENV"] = "test"
require File.expand_path("../config/environment", __dir__)

require "rspec/rails"

Dir[Rails.root.join("spec", "support", "**", "*.rb")].sort.each { |f| require f }

ApplicationController.lark_client = FakeLarkClient.new
