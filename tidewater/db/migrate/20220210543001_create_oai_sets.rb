class CreateOaiSets < ActiveRecord::Migration[7.0]
  def change
    unless table_exists?(:oai_sets)
      create_table :oai_sets do |t|
        t.string :source_iri, unique: true, null: false
        t.string :name, null: false
        t.timestamps
      end

      add_index :oai_sets, :source_iri
      add_index :oai_sets, :name
    end
  end
end
