# frozen_string_literal: true

class TidewaterRabbitmqListener < RabbitmqListener
  def initialize(platform_name: :tidewater)
    super
  end
end
