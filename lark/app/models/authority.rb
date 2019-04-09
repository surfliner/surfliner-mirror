# frozen_string_literal: true

##
# @abstract An abstract Authority record built from/saved to the index.
class Authority < Valkyrie::Resource
  ##
  # @return [String] constant
  def scheme
    self.class::SCHEMA
  end
end
