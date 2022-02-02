class AddSourceIriToOaiItems < ActiveRecord::Migration[7.0]
  def change
    add_column :oai_items, :source_iri, :text, null: false
    add_index :oai_items, :source_iri
  end
end
