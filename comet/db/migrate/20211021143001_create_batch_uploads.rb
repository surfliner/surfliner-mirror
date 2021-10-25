class CreateBatchUploads < ActiveRecord::Migration[5.2]
  def change
    unless table_exists?(:batch_uploads)
      create_table :batch_uploads do |t|
        t.string :batch_id, unique: true, null: false
        t.string :source_file
        t.string :files_path
        t.references :user, foreign_key: false
        t.datetime :created_at, default: "now()", null: false
      end

      add_index "batch_uploads", ["created_at"], name: "index_batch_uploads_created_at"
    end
  end
end
