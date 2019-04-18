# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table :events do
      rename_column :created_at, :date_created
    end
  end
end
