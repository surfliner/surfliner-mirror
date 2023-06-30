module Comet
  ##
  # Mixin providing OpenTelemetry for dry-events Publisher behavior
  module PublisherOtelBehavior
    def publish(event_id, *)
      Comet.tracer.in_span("dry-events publish") do |span|
        span.add_attributes("code.function" => __method__.to_s,
          "surfliner.dry.event_id" => event_id)
        super
      end
    end
  end

  module PublisherBusOtelBehavior
    def publish(event_id, payload)
      process(event_id, payload) do |event, listener|
        Comet.tracer.in_span("dry-events listener") do |span|
          span.add_attributes(
            "surfliner.dry.event_id" => event.id,
            OpenTelemetry::SemanticConventions::Trace::CODE_FILEPATH => listener.source_location[0],
            OpenTelemetry::SemanticConventions::Trace::CODE_LINENO => listener.source_location[1]
          )

          if listener.is_a?(Method)
            span.add_attributes(
              OpenTelemetry::SemanticConventions::Trace::CODE_NAMESPACE => listener.owner.name,
              OpenTelemetry::SemanticConventions::Trace::CODE_FUNCTION => listener.name.to_s
            )
          end

          listener.call(event)
        end
      end
    end
  end
end
