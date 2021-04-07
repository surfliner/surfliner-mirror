# A collection class that does nothing, just to satisfy Hyrax
class Collection < ActiveFedora::Base
  include Hyrax::CollectionBehavior
end
