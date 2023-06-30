unless ENV["OTEL_SDK_DISABLED"] == "true"
  OpenTelemetry::SDK.configure do |c|
    c.service_name = "surfliner-shoreline"
    c.use_all # enables all instrumentation!
  end
end
