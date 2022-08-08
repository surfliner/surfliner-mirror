# frozen_string_literal: true

namespace :comet do
  namespace :rabbitmq do
    desc "Delete a rabbitmq exchange"
    task :delete_exchange, [:exchange] => [:environment] do |t, args|
      exchange_name = args.fetch(:exchange)
      channel = Rails.application.config.rabbitmq_connection.create_channel

      channel.topic(exchange_name).delete
    end
  end
end
