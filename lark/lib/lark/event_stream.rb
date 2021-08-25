# frozen_string_literal: true

require "dry/events/publisher"

module Lark
  ##
  # The stream tracking events system-wide. This is a `Singleton`, meaning there
  # is exactly one `.instance` and `EventStream.new` is private.
  #
  # @example adding an event to the stream
  #   EventStream.instance << event
  #
  # @example subscribing to the stream with a block listener
  #   EventStream.instance.subscribe('created') do |event|
  #     # do something with the event
  #   end
  #
  # @example subscribing to the stream with a listener class
  #   class MyListener
  #     def on_created(event)
  #       # do something with the event
  #     end
  #   end
  #
  #   listener = MyListener.new
  #
  #   EventStream.instance.subscribe(listener)
  #
  # @see Singleton
  class EventStream
    extend Forwardable
    include Singleton

    ##
    # @!attribute [r] name
    #   @return [Publisher]
    attr_reader :publisher

    ##
    # @param publisher [#publish_event]
    def initialize(publisher: Publisher.new)
      @publisher = publisher
    end

    ##
    # @param event [Event]
    #
    # @return [Event]
    def <<(event)
      publisher.publish_event(event)

      adapter.persister.save(resource: event)
    end

    ##
    # Retrieve the Valkyrie adapter for event
    #
    # @return [Valkyrie::MetadataAdapter]
    def adapter
      Valkyrie::MetadataAdapter.find(Lark.config.event_adapter)
    end

    ##
    # @!method subscribe(listener)
    #   @overload subscribe(event_name, &block)
    #     @param event_name [String]
    #     @yield [event]
    #   @overload subscribe(listener)
    #     @param listener [#on_created]
    def_delegator :@publisher, :subscribe

    ##
    # A publisher for the `Dry::Events` pub/sub system. Whenever an event is
    # persisted to the `EventStream`, it should also also get published here.
    #
    # @see https://dry-rb.org/gems/dry-events/
    class Publisher
      include Dry::Events::Publisher[:lark]

      EVENT_TYPES = {
        create: "created",
        change_properties: "properties_changed"
      }.freeze

      EVENT_TYPES.each_value { |name| register_event(name) }

      ##
      # Interprets a given `Event` object and publishes it to subscribers.
      #
      # @param event [Event]
      #
      # @return [void]
      #
      # @see Dry::Events::Publisher
      def publish_event(event)
        publish(EVENT_TYPES[event.type], event.data)
      end
    end
  end
end
