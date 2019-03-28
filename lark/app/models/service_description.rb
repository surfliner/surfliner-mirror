# frozen_string_literal: true

##
# A service description for the API
class ServiceDescription
  class << self
    def to_json
      new.to_json
    end
  end

  ##
  # @return [String] the api version
  def version
    '0.1.0'
  end

  ##
  # @return [String] a JSON service description
  def to_json
    to_h.to_json
  end

  ##
  # @return [Hash] a hash representation of this object
  def to_h
    { version: version }
  end
end
