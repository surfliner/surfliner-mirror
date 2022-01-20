class CreateOaiItems < ActiveRecord::Migration[7.0]
  def change
    create_table :oai_items do |t|
      t.text :title
      t.text :creator
      t.text :description
      t.text :publisher
      t.text :contributor
      t.text :date
      t.text :type
      t.text :format
      t.text :identifier
      t.text :source
      t.text :subject
      t.text :language
      t.text :relation
      t.text :coverage
      t.text :rights

      t.timestamps
    end
  end
end
