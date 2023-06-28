OpenTelemetry::SDK.configure do |c|
  c.service_name = "surfliner-comet"
  c.use_all # enables all instrumentation!
end
