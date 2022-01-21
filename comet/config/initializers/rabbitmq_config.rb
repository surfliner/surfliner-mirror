# frozen_string_literal: true

require "bunny"

rabbitmq_host = ENV.fetch("RABBITMQ_HOST", "rabbitmq")
rabbitmq_user = ENV.fetch("RABBITMQ_USERNAME", "user")
rabbitmq_password = ENV.fetch("RABBITMQ_PASSWORD", "bitnami")
rabbitmq_port = ENV.fetch("RABBITMQ_NODE_PORT_NUMBER", 5672)

conn_url = "amqp://#{rabbitmq_user}:#{rabbitmq_password}@#{rabbitmq_host}:#{rabbitmq_port}"
puts "Rabbitmq message broker connection url: #{conn_url}"

conn = Bunny.new(conn_url)
Rails.application.config.rabbitmq_connection = conn
