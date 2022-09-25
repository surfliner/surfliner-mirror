class AddAdminSetIdToBatchUploads < ActiveRecord::Migration[5.2]
  def change
    add_column :batch_uploads, :admin_set_id, :string
  end
end
