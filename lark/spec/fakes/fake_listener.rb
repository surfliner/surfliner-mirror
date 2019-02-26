# frozen_string_literal: true

##
# A spy listener. stores events published to subscribed streams in
# `#events` for later inspection
class FakeListener
  attr_reader :events

  def initialize
    @events = []
  end

  def on_created(event)
    events << event
  end
end
