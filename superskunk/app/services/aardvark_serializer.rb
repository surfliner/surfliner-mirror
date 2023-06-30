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
      iri: "http://purl.org/dc/terms/accessRights",
      singular: true
    },
    dct_alternative_sm: { # Alternative Title
      iri: "http://purl.org/dc/terms/alternative"
    },
    dcat_bbox: { # Bounding Box
      iri: "https://www.w3.org/ns/dcat#bbox",
      singular: true
    },
    dcat_centroid: { # Centroid
      iri: "https://www.w3.org/ns/dcat#centroid",
      singular: true
    },
    dct_creator_sm: { # Creator
      iri: "http://purl.org/dc/terms/creator"
    },
    dct_issued_s: { # Date Issued
      iri: "http://purl.org/dc/terms/issued",
      singular: true
    },
    gbl_dateRange_drsim: { # Date Range
      iri: "https://opengeometadata.org/docs/ogm-aardvark/date-range"
    },
    dct_description_sm: { # Description
      iri: "http://purl.org/dc/terms/description"
    },
    gbl_fileSize_s: { # File Size
      iri: "https://opengeometadata.org/docs/ogm-aardvark/file-size",
      singular: true
    },
    dct_format_s: { # Format
      iri: "http://purl.org/dc/terms/format",
      singular: true
    },
    locn_geometry: { # Geometry
      iri: "http://www.w3.org/ns/locn#geometry",
      singular: true
    },
    gbl_georeferenced_b: { # Georeferenced
      iri: "https://opengeometadata.org/docs/ogm-aardvark/georeferenced",
      singular: true,
      type: :boolean
    },
    id: { # ID (REQUIRED)
      iri: "@id",
      singular: true
    },
    dct_identifier_sm: { # Identifier
      iri: "http://purl.org/dc/terms/identifier"
    },
    gbl_indexYear_im: { # Index Year
      iri: "https://opengeometadata.org/docs/ogm-aardvark/index-year",
      type: :integer
    },
    dct_isPartOf_sm: { # Is Part Of
      iri: "http://purl.org/dc/terms/isPartOf"
    },
    dct_isReplacedBy_sm: { # Is Replaced By
      iri: "http://purl.org/dc/terms/isReplacedBy"
    },
    dct_isVersionOf_sm: { # Is Version Of
      iri: "http://purl.org/dc/terms/isVersionOf"
    },
    dcat_keyword_sm: { # Keyword
      iri: "http://purl.org/dc/terms/keyword"
    },
    dct_language_sm: { # Language
      iri: "http://purl.org/dc/terms/language"
    },
    dct_license_sm: { # License
      iri: "http://purl.org/dc/terms/license"
    },
    pcdm_memberOf_sm: { # Member Of
      iri: "http://pcdm.org/models#memberOf"
    },
    gbl_mdVersion_s: { # Metadata Version (REQUIRED)
      iri: "https://opengeometadata.org/docs/ogm-aardvark/metadata-version",
      singular: true
    },
    gbl_mdModified_dt: { # Modified (REQUIRED)
      iri: "https://opengeometadata.org/docs/ogm-aardvark/modified",
      singular: true
    },
    schema_provider_s: { # Provider
      iri: "https://schema.org/provider",
      singular: true
    },
    dct_publisher_sm: { # Publisher
      iri: "http://purl.org/dc/terms/publisher"
    },
    dct_references_s: { # References
      iri: "http://purl.org/dc/terms/references",
      singular: true
    },
    dct_relation_sm: { # Relation
      iri: "http://purl.org/dc/terms/relation"
    },
    dct_replaces_sm: { # Replaces
      iri: "http://purl.org/dc/terms/replaces"
    },
    gbl_resourceClass_sm: { # Resource Class (REQUIRED)
      iri: "https://opengeometadata.org/docs/ogm-aardvark/resource-class"
    },
    gbl_resourceType_sm: { # Resource Type
      iri: "https://opengeometadata.org/docs/ogm-aardvark/resource-type"
    },
    dct_rightsHolder_sm: { # Rights Holder
      iri: "http://purl.org/dc/terms/rightsHolder"
    },
    dct_rights_sm: { # Rights
      iri: "http://purl.org/dc/terms/rights"
    },
    dct_source_sm: { # Source
      iri: "http://purl.org/dc/terms/source"
    },
    dct_spatial_sm: { # Spatial Coverage
      iri: "http://purl.org/dc/terms/spatial"
    },
    dct_subject_sm: { # Subject
      iri: "http://purl.org/dc/terms/subject"
    },
    gbl_suppressed_b: { # Suppressed
      iri: "https://opengeometadata.org/docs/ogm-aardvark/suppressed",
      singular: true,
      type: :boolean
    },
    dct_temporal_sm: { # Temporal Coverage
      iri: "http://purl.org/dc/terms/temporal"
    },
    dcat_theme_sm: { # Theme
      iri: "http://www.w3.org/ns/dcat#theme"
    },
    dct_title_s: { # Title (REQUIRED)
      iri: "http://purl.org/dc/terms/title",
      singular: true
    },
    gbl_wxsIdentifier_s: { # WxS Identifier
      iri: "https://opengeometadata.org/docs/ogm-aardvark/wxs-identifier",
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
        mapping << resource.id
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
      when :_file_urls
        mapping = file_sets_for(resource: resource).map { |id| signed_url_for(id: id) }
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
  def signed_url_for(id:)
    "#{ENV["COMET_BASE"]}/downloads/#{id}?use=service_file"
  end

  ##
  # Concats four values (bounding_box_west, bounding_box_east, bounding_box_north, bounding_box_south)
  # to a single bounding box value for aardvark
  # Aardvark expects value to be in this format ENVELOPE(-93.947768,-86.764686,21.567248,13.156171)
  def concatenated_bounding_box
    bbox_keys = [:bounding_box_west, :bounding_box_east, :bounding_box_north, :bounding_box_south]
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
