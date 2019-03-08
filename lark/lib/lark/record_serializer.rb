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
      when 'application/json'
        new
      else
        raise UnsupportedMediaType, content_type
      end
    end

    ##
    # @param record [#attributes]
    #
    # @return [String] a serialized string representing the record
    def serialize(record:)
      reserved_attributes = record.class.reserved_attributes
      record.attributes
            .except(*reserved_attributes)
            .merge(id: record.id.to_s)
            .to_json
    end
  end
end
