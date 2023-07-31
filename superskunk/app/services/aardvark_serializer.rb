##
# A resource serializer for Open GeoMetadata Aardvark.
class AardvarkSerializer < ResourceSerializer
  ##
  # A mapping of Open GeoMetadata Aardvark terms to definition hashes which
  # provide us the information needed to process them.
  #
  # We currently use the corresponding documentation URLs for +gbl_+ terms,
  # although it’s not clear that these have strong stability guarantees (we may
  # need to change them later).
  AARDVARK_TERMS = {
    dct_accessRights_s: { # Access Rights (REQUIRED)
      iri: "https://opengeometadata.org/ogm-aardvark/#access-rights",
      singular: true
    },
    dct_alternative_sm: { # Alternative Title
      iri: "https://opengeometadata.org/ogm-aardvark/#alternative-title"
    },
    dcat_bbox: { # Bounding Box
      iri: "https://opengeometadata.org/ogm-aardvark/#bounding-box",
      singular: true
    },
    dcat_centroid: { # Centroid
      iri: "https://opengeometadata.org/ogm-aardvark/#centroid",
      singular: true
    },
    dct_creator_sm: { # Creator
      iri: "https://opengeometadata.org/ogm-aardvark/#creator"
    },
    dct_issued_s: { # Date Issued
      iri: "https://opengeometadata.org/ogm-aardvark/#date-issued",
      singular: true
    },
    gbl_dateRange_drsim: { # Date Range
      iri: "https://opengeometadata.org/ogm-aardvark/#date-range"
    },
    dct_description_sm: { # Description
      iri: "https://opengeometadata.org/ogm-aardvark/#description"
    },
    gbl_displayNote_sm: { # Display Note
      iri: "https://opengeometadata.org/ogm-aardvark/#display-note"
    },
    gbl_fileSize_s: { # File Size
      iri: "https://opengeometadata.org/ogm-aardvark/#file-size",
      singular: true
    },
    dct_format_s: { # Format
      iri: "https://opengeometadata.org/ogm-aardvark/#format",
      singular: true
    },
    locn_geometry: { # Geometry
      iri: "https://opengeometadata.org/ogm-aardvark/#geometry",
      singular: true
    },
    gbl_georeferenced_b: { # Georeferenced
      iri: "https://opengeometadata.org/ogm-aardvark/#georeferenced",
      singular: true,
      type: :boolean
    },
    id: { # ID (REQUIRED)
      iri: "https://opengeometadata.org/ogm-aardvark/#id",
      singular: true
    },
    dct_identifier_sm: { # Identifier
      iri: "https://opengeometadata.org/ogm-aardvark/#identifier"
    },
    gbl_indexYear_im: { # Index Year
      iri: "https://opengeometadata.org/ogm-aardvark/#index-year",
      type: :integer
    },
    dct_isPartOf_sm: { # Is Part Of
      iri: "https://opengeometadata.org/ogm-aardvark/#is-part-of"
    },
    dct_isReplacedBy_sm: { # Is Replaced By
      iri: "https://opengeometadata.org/ogm-aardvark/#is-replaced-by"
    },
    dct_isVersionOf_sm: { # Is Version Of
      iri: "https://opengeometadata.org/ogm-aardvark/#is-version-of"
    },
    dcat_keyword_sm: { # Keyword
      iri: "https://opengeometadata.org/ogm-aardvark/#keyword"
    },
    dct_language_sm: { # Language
      iri: "https://opengeometadata.org/ogm-aardvark/#language"
    },
    dct_license_sm: { # License
      iri: "https://opengeometadata.org/ogm-aardvark/#license"
    },
    pcdm_memberOf_sm: { # Member Of
      iri: "https://opengeometadata.org/ogm-aardvark/#member-of"
    },
    gbl_mdVersion_s: { # Metadata Version (REQUIRED)
      iri: "https://opengeometadata.org/ogm-aardvark/#metadata-version",
      singular: true
    },
    gbl_mdModified_dt: { # Modified (REQUIRED)
      iri: "https://opengeometadata.org/ogm-aardvark/#modified",
      singular: true
    },
    schema_provider_s: { # Provider
      iri: "https://opengeometadata.org/ogm-aardvark/#provider",
      singular: true
    },
    dct_publisher_sm: { # Publisher
      iri: "https://opengeometadata.org/ogm-aardvark/#publisher"
    },
    dct_references_s: { # References
      iri: "https://opengeometadata.org/ogm-aardvark/#references",
      singular: true
    },
    dct_relation_sm: { # Relation
      iri: "https://opengeometadata.org/ogm-aardvark/#relation"
    },
    dct_replaces_sm: { # Replaces
      iri: "https://opengeometadata.org/ogm-aardvark/#replaces"
    },
    gbl_resourceClass_sm: { # Resource Class (REQUIRED)
      iri: "https://opengeometadata.org/ogm-aardvark/#resource-class"
    },
    gbl_resourceType_sm: { # Resource Type
      iri: "https://opengeometadata.org/ogm-aardvark/#resource-type"
    },
    dct_rightsHolder_sm: { # Rights Holder
      iri: "https://opengeometadata.org/ogm-aardvark/#rights-holder"
    },
    dct_rights_sm: { # Rights
      iri: "https://opengeometadata.org/ogm-aardvark/#rights_1"
    },
    dct_source_sm: { # Source
      iri: "https://opengeometadata.org/ogm-aardvark/#source"
    },
    dct_spatial_sm: { # Spatial Coverage
      iri: "https://opengeometadata.org/ogm-aardvark/#spatial-coverage"
    },
    dct_subject_sm: { # Subject
      iri: "https://opengeometadata.org/ogm-aardvark/#subject"
    },
    gbl_suppressed_b: { # Suppressed
      iri: "https://opengeometadata.org/ogm-aardvark/#suppressed",
      singular: true,
      type: :boolean
    },
    dct_temporal_sm: { # Temporal Coverage
      iri: "https://opengeometadata.org/ogm-aardvark/#temporal-coverage"
    },
    dcat_theme_sm: { # Theme
      iri: "https://opengeometadata.org/ogm-aardvark/#theme"
    },
    dct_title_s: { # Title (REQUIRED)
      iri: "https://opengeometadata.org/ogm-aardvark/#title",
      singular: true
    },
    gbl_wxsIdentifier_s: { # WxS Identifier
      iri: "https://opengeometadata.org/ogm-aardvark/#wxs-identifier",
      singular: true
    },
    _file_urls: { # fake field for storing S3 URLs to shapefiles
      iri: "http://pcdm.org/models#hasMember"
    }
  }

  ##
  # Returns a hash representing the JSON-LD which represents the resource as
  # Open GeoMetadata Aardvark.
  def to_jsonld
    AARDVARK_TERMS.each_with_object({
      "@context" => {"@base": "#{ENV["SUPERSKUNK_API_BASE"]}/resources/"}
    }) do |(term, dfn), json|
      mapping = mappings[dfn[:iri]].to_a

      # Special handling for specific terms.
      #
      # In particular, we want to make sure there are fallbacks for all
      # REQUIRED terms.
      case term
      when :dct_accessRights_s
        # For now we only support "Public" access.
        mapping = ["Public"] unless mapping.present?
      when :dct_isPartOf_sm
        mapping = Superskunk.comet_query_service.custom_queries.find_parent_work_id(resource: resource) || []
      when :pcdm_memberOf_sm
        mapping = resource.member_of_collection_ids
      when :dcat_bbox, :locn_geometry
        # Both use concatenated bounding_box_ values
        mapping = concatenated_bounding_box
      when :id
        # Add the +:id+.
        mapping << (resource.ark || resource.id)
      when :gbl_mdVersion_s
        # The default value for +:gbl_mdVersion_s+ should be +Aardvark+.
        mapping = ["Aardvark"] unless mapping.present?
      when :gbl_mdModified_dt
        # ensure we're using the correct format
        mapping = mapping.map { |date| DateTime.parse(date).strftime("%FT%TZ") }
        # +:gbl_mdModified_dt+ falls back to the Hyrax last modified metadata.
        mapping = resource.date_modified.map { |datetime| datetime.strftime("%FT%TZ") } unless mapping.present?
        mapping = [DateTime.now.iso8601] unless mapping.present? # extra fallback
      when :gbl_resourceClass_sm
        # +:gbl_resourceClass_sm+ defaults to "Datasets".
        mapping = ["Datasets"] unless mapping.present?
      when :dct_title_s
        # At present, +:dct_title_s+ is provided by Hyrax, not the schema.
        mapping += resource.title.to_a
      when :schema_provider_s
        mapping = Array(resource.class.reader.profile.to_h.dig(:additional_metadata, :ogm_provider_name))
      when :dct_language_sm
        mapping.map! do |lang_code|
          iso639_2_code = ISO_639.find_by_code(lang_code.to_s)
          unless iso639_2_code
            Rails.logger.warn("#{lang_code} cannot be converted to an iso639-2 3 character code.")
            next nil
          end
          iso639_2_code.alpha3_bibliographic
        end.compact!
      when :dct_references_s
        mapping = [{
          "http://schema.org/downloadUrl": file_sets_for(resource: resource).map do |id|
                                             {
                                               label: resource.format_geo.first&.value || "Shapefile",
                                               url: signed_url_for(id: id, use: :preservation_file, internal: false)
                                             }
                                           end
        }.to_json]
      when :_file_urls
        mapping = file_sets_for(resource: resource).map do |id|
          signed_url_for(id: id, use: :service_file, internal: true)
        end
      end

      # Cast mappings to the appropriate types.
      case dfn[:type]
      when :boolean
        mapping.map! { |v| (v == "false") ? false : v.present? }
      when :integer
        mapping.map! { |v| v.object.is_a?(Date) ? v.object.year : v.object }
      else
        mapping.map!(&:to_s)
      end

      # Replace non‐multi·valued terms with their single values.
      mapping = mapping.first if dfn[:singular]

      # Add mappings to the resultant Json if present.
      if mapping.present?
        json[term] = mapping
        json["@context"][term] = dfn[:iri]
      end
    end
  end

  private

  # @param [Valkyrie::Resource] resource
  # @return [Array<Valkyrie::ID>]
  def file_sets_for(resource:)
    qs = Superskunk::CustomQueries::ChildFileSetsNavigator.new(
      query_service: Superskunk.comet_query_service
    )

    qs.find_child_file_set_ids(resource: resource)
  end

  # @param [Valkyrie::ID] id
  # @return [String]
  def signed_url_for(id:, use: :service_file, internal: false)
    base_url = internal ? ENV["COMET_BASE"] : ENV["COMET_EXTERNAL_BASE"]

    "#{base_url}/downloads/#{id}?use=#{use}&use_internal_endpoint=#{internal}"
  end

  ##
  # Concats four values (bounding_box_west, bounding_box_east, bounding_box_north, bounding_box_south)
  # to a single bounding box value for aardvark
  # Aardvark expects value to be in this format ENVELOPE(-93.947768,-86.764686,21.567248,13.156171)
  def concatenated_bounding_box
    bbox_keys = [:bounding_box_west_geo, :bounding_box_east_geo, :bounding_box_north_geo, :bounding_box_south_geo]
    all_keys_present = true
    bbox_keys.each do |k|
      unless resource[k].present?
        Rails.logger.warn("#{k} not present, unable to create dcat_bbox and locn_geometry mapping")
        all_keys_present = false
      end
    end
    return [] unless all_keys_present
    Array("ENVELOPE(#{bbox_keys.map { |k| resource[k].first }.join(",")})")
  end
end
