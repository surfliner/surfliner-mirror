# `OkComputer` is included in Hyrax when the gem is available.
# See hyrax/config/initializers/1_healthz.rb for the upstream configuration

class RabbitMqCheck < OkComputer::Check
  def initialize(connection)
    @connection = connection
  end

  def check
    mark_failure unless @connection.open?
    mark_message "RabbitMq connection status #{@connection.status}. #{@connection.host}:#{@connection.port}"
  end
end

OkComputer::Registry.register("rabbitmq", RabbitMqCheck.new(Rails.application.config.rabbitmq_connection)) if
  Rails.application.config.use_rabbitmq
