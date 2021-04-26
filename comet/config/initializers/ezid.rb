# frozen_string_literal: true

require "ezid-client"

Ezid::Client.configure do |config|
  config.default_shoulder = ENV.fetch("EZID_SHOULDER", "ark:/99999/fk4")
  config.logger = Rails.logger
  config.password = ENV["EZID_PASSWORD"]
  config.user = ENV.fetch("EZID_USERNAME", "apitest")
end
