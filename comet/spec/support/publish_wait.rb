# Wait for publishing
def publish_wait(*messages, &block)
  begin_count = messages.length
  begin_time = Time.now
  sleep 1.seconds and puts "Waiting on receiving message " until Time.now > (begin_time + 10) ||
      messages.length > begin_count
end
