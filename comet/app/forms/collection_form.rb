# frozen_string_literal: true

##
# @see https://github.com/samvera/valkyrie/wiki/ChangeSets-and-Dirty-Tracking
class CollectionForm < Valkyrie::ChangeSet
  property :title, required: true
  property :depositor, required: true
  property :collection_type_gid, required: true

  class << self
    def model_class
      Hyrax::PcdmCollection
    end

    def primary_terms
      ["title"]
    end

    def secondary_terms
      []
    end
  end

  def primary_terms
    self.class.primary_terms
  end

  def secondary_terms
    self.class.secondary_terms
  end

  def display_additional_fields?
    secondary_terms.any?
  end
end
