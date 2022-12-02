# frozen_string_literal: true

module Bulkrax
  class ValkyrieObjectFactory < ObjectFactory
    ##
    # Retrieve properties from M3 model
    # @param klass the model
    # return Array<string>
    def self.schema_properties(klass)
      @schema_properties ||= ::SchemaLoader.new.properties_for(klass.name.underscore.to_sym).values.map { |pro| pro.name.to_s }
    end

    def run!
      run
      # Create the error exception if the object is not validly saved for some reason
      raise RecordInvalid, object if !object.persisted?
      object
    end

    def find_by_id
      Hyrax.query_service.find_by(id: attributes[:id]) if attributes.key? :id
    end

    def search_by_identifier
      # Query can return partial matches (something6 matches both something6 and something68)
      # so we need to weed out any that are not the correct full match. But other items might be
      # in the multivalued field, so we have to go through them one at a time.
      match = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: source_identifier_value)

      return match if match
    rescue => err
      Hyrax.logger.error(err)
      false
    end

    # An ActiveFedora bug when there are many habtm <-> has_many associations means they won't all get saved.
    # https://github.com/projecthydra/active_fedora/issues/874
    # 2+ years later, still open!
    def create
      attrs = transform_attributes
      @object = klass.new(alternate_ids: [source_identifier_value])
      @object.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX if @object.respond_to?(:reindex_extent)
      run_callbacks :save do
        run_callbacks :create do
          if klass == Collection
            create_collection(attrs)
          elsif klass == FileSet
            create_file_set(attrs)
          else
            @object = persist_metadata(resource: @object, attrs: attrs)
          end
        end
      end

      @object = apply_depositor_metadata(@object, @user) if @object.depositor.nil?
      log_created(@object)
    end

    def update
      raise "Object doesn't exist" unless @object
      destroy_existing_files if @replace_files && ![Collection, FileSet].include?(klass)
      attrs = transform_attributes(update: true)
      run_callbacks :save do
        if klass == Collection
          update_collection(attrs)
        elsif klass == FileSet
          update_file_set(attrs)
        else
          @object = persist_metadata(resource: @object, attrs: attrs)
        end
      end
      @object = apply_depositor_metadata(@object, @user) if @object.depositor.nil?
      log_updated(@object)
    end

    def persist_metadata(resource:, attrs:)
      attrs.each { |k, v| resource.public_send("#{k}=", v) if resource.respond_to?(k.to_s) }
      object = Hyrax.persister.save(resource: resource)
      # Index the object
      Hyrax.publisher.publish("object.metadata.updated", object: object, user: @user)
      object
    end

    ##
    # TODO: What else fields are necessary: %i[id edit_users edit_groups read_groups visibility work_members_attributes admin_set_id]?
    # Regardless of what the Parser gives us, these are the properties we are prepared to accept.
    def permitted_attributes
      Bulkrax::ValkyrieObjectFactory.schema_properties(klass) + %i[title]
    end

    def apply_depositor_metadata(object, user)
      object.depositor = user.email
      object = Hyrax.persister.save(resource: object)
      Hyrax.publisher.publish("object.metadata.updated", object: object, user: @user)
      object
    end
  end

  class RecordInvalid < StandardError
  end
end
