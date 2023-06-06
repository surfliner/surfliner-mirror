# frozen_string_literal: true

module Lark
  ##
  # @abstract A serializer for authority records. Classes implementing this
  #   abstract interface should provide a `#serialize(record:)` method returning
  #   a serialized string. This is the inverse of `Lark::RecordParser`. A
  #   parser/serializer pair with the same `content_type` should be capable of
  #   round-tripping records.
  #
  class RecordSerializer
    ##
    # @param content_type [String]
    #
    # @return [#serialize]
    def self.for(content_type:)
      case content_type
      when "application/json"
        Lark::RecordSerializers::JsonSerializer.new
      else
        raise UnsupportedMediaType, content_type
      end
    end

    ##
    # @param record [#attributes]
    #
    # @return [String] a serialized string representing the record
    def serialize(record:)
      raise NotImplementedError
    end
  end
end
