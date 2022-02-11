# frozen_string_literal: true

class OaiSetEntry < ApplicationRecord
  belongs_to :oai_set
  belongs_to :oai_item
end
