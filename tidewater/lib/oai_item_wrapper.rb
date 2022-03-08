require "active_record"

module Tidewater
  # This class inherits an OAI::Provider::ActiveRecordWrapper model
  # For more details see https://github.com/code4lib/ruby-oai/blob/master/lib/oai/provider/model/activerecord_wrapper.rb#L95

  class OaiItemWrapper < OAI::Provider::ActiveRecordWrapper
    protected

    def find_scope(options)
      return model unless options.key?(:set)

      # Find the set or return an empty scope
      set = find_set_by_spec(options[:set])

      return model.limit(0) if set.nil?
      # If the set has a backward relationship, we'll use it
      if set.class.respond_to?(:reflect_on_all_associations)
        set.class.reflect_on_all_associations.each do |assoc|
          return set.send(assoc.name) if assoc.klass == model
        end
      end

      set_entry = OaiSetEntry.find_by(oai_set_id: set.id)
      model.where(id: set_entry.oai_item_id)
    end
  end
end
