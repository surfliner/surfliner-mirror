# frozen_string_literal: true

class OaiSetEntry < ApplicationRecord
  self.table_name = "oai_set_entries"

  belongs_to :oai_set
  belongs_to :oai_item
end
