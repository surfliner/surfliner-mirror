module Lark
  ##
  # The stream tracking events system-wide. This is a `Singleton`, meaning there
  # is exactly one `.instance` and `EventStream.new` is private.
  #
  # @example adding an event to the stream
  #   EventStream.instance << event
  #
  # @see Singleton
  class EventStream
    include Singleton

    ##
    # @param event [Event]
    #
    # @return [Event]
    def <<(event)
      event
    end
  end
end
