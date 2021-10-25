class CreateBatchUploadEntries < ActiveRecord::Migration[5.2]
  def change
    unless table_exists?(:batch_upload_entries)
      create_table :batch_upload_entries do |t|
        t.references :batch_upload, foreign_key: {to_table: :batch_uploads}, null: false
        t.references :entity, foreign_key: {to_table: :sipity_entities}
        t.jsonb :raw_metadata
        t.datetime :created_at, default: "now()", null: false
      end

      add_index "batch_upload_entries", ["created_at"], name: "index_batch_upload_entries_created_at"
      add_index "batch_upload_entries", ["raw_metadata"], using: :gin, name: "index_batch_upload_entries_raw_metadata"
    end
  end
end
