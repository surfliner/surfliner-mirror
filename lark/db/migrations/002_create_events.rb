# frozen_string_literal: true

Sequel.migration do
  up do
    run 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp"'
    create_table :events, id: false do
      column :id, :uuid, index: true
      column :data, :jsonb, default: '{}', index: { type: :gin }
      String :type, index: true
      DateTime :created_at, index: true, default: ::Sequel::CURRENT_TIMESTAMP
    end
    run 'CREATE INDEX events_data_index_pathops ON events USING gin (data jsonb_path_ops)'
    run "GRANT ALL PRIVILEGES ON events TO #{ENV.fetch("POSTGRES_USER")}"
  end
  down do
    drop_table :events
    run 'DROP EXTENSION "uuid-ossp"'
  end
end
