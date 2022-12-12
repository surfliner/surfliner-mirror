# frozen_string_literal: true

require "date"

module Shoreline
  # Methods for handling Aardvark metadata
  module Aardvark
    # Solr values that are copied as-is from GBL 1.0 to Aardvark
    PRESERVED_VALUES = %i[
      dct_issued_s
      dct_references_s
      dct_spatial_sm
      dct_temporal_sm
    ].freeze

    # Solr values that are mapped from one key to another without a change in
    # cardinality
    MAPPED_VALUES_SAME_CARDINALITY = {
      dc_creator_sm: :dct_creator_sm,
      dc_format_s: :dct_format_s,
      dc_language_sm: :dct_language_sm,
      dc_publisher_sm: :dct_publisher_sm,
      dc_rights_s: :dct_accessRights_s,
      dc_source_sm: :dct_source_sm,
      dc_subject_sm: :dct_subject_sm,
      dct_isPartOf_sm: :pcdm_memberOf_sm,
      dc_title_s: :dct_title_s,
      dct_provenance_s: :schema_provider_s,
      geoblacklight_version: :gbl_mdVersion_s,
      layer_id_s: :gbl_wxsIdentifier_s,
      layer_slug_s: :id,
      solr_geom: :dcat_bbox,
      suppressed_b: :gbl_suppressed_b
    }.freeze

    # Solr values that need to be converted to multi-valued
    MAPPED_VALUES_SINGLE_TO_MULTIVALUE = {
      dc_description_s: :dct_description_sm,
      dc_identifier_s: :dct_identifier_sm,
      solr_year_i: :gbl_indexYear_im
    }.freeze

    NEW_VALUES = {
      dct_rightsHolder_sm: proc { |solr| [solr[:dc_publisher_s]].compact },
      gbl_mdModified_dt: proc { |_solr| DateTime.now.new_offset(0).strftime("%FT%TZ") },
      gbl_mdVersion_s: proc { |_solr| "Aardvark" },
      gbl_resourceClass_sm: proc { |_solr| ["Datasets"] },
      gbl_resourceType_sm: proc { |solr| ["#{solr[:layer_geom_type_s]} data"] },
      locn_geometry: proc { |solr| solr[:solr_geom] }
    }

    # # Solr values that are no longer used in Aardvark and which can be dropped
    # DEPRECATED_VALUES = %i[
    #   dc_type_s
    #   layer_geom_type_s
    #   layer_modified_dt
    # ]

    # @param [Array, Hash] solr
    # @return [Array]
    def self.convert(solr)
      case solr
      when Array
        solr.map { |s| convert_single(s.with_indifferent_access) }
      when Hash
        convert_single(solr.with_indifferent_access)
      else
        raise ArgumentError, "Shoreline::Aardvark#convert requires an Array or Hash"
      end
    end

    # @param [Hash] solr
    # @return [Hash]
    def self.convert_single(solr)
      {}.tap do |hash|
        PRESERVED_VALUES.each do |value|
          hash[value] = solr[value]
        end

        MAPPED_VALUES_SAME_CARDINALITY.each do |k, v|
          hash[v] = solr[k]
        end

        MAPPED_VALUES_SINGLE_TO_MULTIVALUE.each do |k, v|
          hash[v] = [solr[k]].compact
        end

        NEW_VALUES.each do |k, v|
          hash[k] = v.call(solr)
        end
      end.reject { |_k, v| v.blank? }
    end
  end
end
