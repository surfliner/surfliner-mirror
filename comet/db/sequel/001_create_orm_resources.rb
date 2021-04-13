# frozen_string_literal: true

Sequel.migration do
  up do
    create_table :orm_resources do
      column :id, :bigint, identity: true
      column :metadata, :jsonb, default: "{}", index: {type: :gin}
      String :internal_resource, index: true
      Integer :lock_version, index: true
      DateTime :created_at, index: true, default: ::Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, index: true
    end

    run "CREATE INDEX orm_resources_metadata_index_pathops ON orm_resources USING gin (metadata jsonb_path_ops)"
  end

  down do
    drop_table :orm_resources
  end
end
