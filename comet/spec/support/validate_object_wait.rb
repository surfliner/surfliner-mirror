# Wait for object created
def validate_object_wait(alternate_id:)
  begin_time = Time.now
  sleep 1.seconds and puts "Waiting on creating object" until Time.now > (begin_time + 10) ||
      Hyrax.query_service.find_all_of_model(model: GenericObject).find { |o| o.alternate_ids.map { |id| id.to_s }.include?(alternate_id) }
end
