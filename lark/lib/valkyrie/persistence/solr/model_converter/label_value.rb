module Valkyrie
  module Persistence
    module Solr
      class ModelConverter
        class LabelValue < Valkyrie::ValueMapper
          def self.handles?(value)
            value.is_a?(Property) && value.value.is_a?(::Label)
          end

          def result
            # There should be exactly one literal form for each label, but let’s
            # enforce this.
            key = value.key
            literal = value.value.literal_form.to_a.first
            rows = [NestedObjectValue.new(value, calling_mapper).result]
            if literal
              # Do *not* index as :tsim; Valkyrie uses this to store the full
              # resource metadata.
              #
              # Instead, just index as :ssim, which is what we use for
              # searching.
              rows << SolrRow.new(key: key, fields: [:ssim], values: [literal.to_s])
            end
            CompositeSolrRow.new(rows)
          end
        end
      end
    end
  end
end
