class CreateOaiSetEntries < ActiveRecord::Migration[5.2]
  def change
    unless table_exists?(:oai_set_entries)
      create_table :oai_set_entries do |t|
        t.references :oai_set, null: false, foreign_key: {to_table: :oai_sets}
        t.references :oai_item, null: false, foreign_key: {to_table: :oai_items}
        t.timestamps
      end
    end
  end
end
