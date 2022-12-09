##
# A resource serializer for Open GeoMetadata Aardvark.
class AardvarkSerializer < ResourceSerializer
  ##
  # A mapping of Open GeoMetadata Aardvark terms to definition hashes which
  # provide us the information needed to process them.
  #
  # We currently use +http://geoblacklight.org/schema/aardvark/+ as the prefix
  # for +gbl_+ terms, although I’m not sure this has been made standard.
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
      iri: "http://geoblacklight.org/schema/aardvark/dateRange"
    },
    dct_description_sm: { # Description
      iri: "http://purl.org/dc/terms/description"
    },
    gbl_fileSize_s: { # File Size
      iri: "http://geoblacklight.org/schema/aardvark/fileSize",
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
      iri: "http://geoblacklight.org/schema/aardvark/georeferenced",
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
      iri: "http://geoblacklight.org/schema/aardvark/indexYear",
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
      iri: "http://geoblacklight.org/schema/aardvark/mdVersion",
      singular: true
    },
    gbl_mdModified_dt: { # Modified (REQUIRED)
      iri: "http://geoblacklight.org/schema/aardvark/mdModified",
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
      iri: "http://geoblacklight.org/schema/aardvark/resourceClass"
    },
    gbl_resourceType_sm: { # Resource Type
      iri: "http://geoblacklight.org/schema/aardvark/resourceType"
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
      iri: "http://geoblacklight.org/schema/aardvark/suppressed",
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
      iri: "http://geoblacklight.org/schema/aardvark/wxsIdentifier",
      singular: true
    }
  }

  ##
  # Returns a hash representing the JSON-LD which represents the resource as
  # Open GeoMetadata Aardvark.
  def to_jsonld
    AARDVARK_TERMS.each_with_object({
      "@context" => {"@base": "#{ENV["SUPERSKUNK_API_BASE"]}/resources/"}
    }) do |(term, dfn), json|
      mapping = mappings.values
        .select { |mapping| mapping[:property_iri] == dfn[:iri] }
        .map { |prop| prop[:value].to_a }.flatten

      # Special handling for specific terms.
      #
      # In particular, we want to make sure there are fallbacks for all
      # REQUIRED terms.
      case term
      when :dct_accessRights_s
        # For now we only support "Public" access.
        mapping = ["Public"] unless mapping.present?
      when :id
        # Add the +:id+.
        mapping << resource.id
      when :gbl_mdVersion_s
        # The default value for +:gbl_mdVersion_s+ should be +Aardvark+.
        mapping = ["Aardvark"] unless mapping.present?
      when :gbl_mdModified_dt
        # +:gbl_mdModified_dt+ falls back to the Hyrax last modified metadata.
        mapping = resource.date_modified unless mapping.present?
        mapping = [Time.now.iso8601] unless mapping.present? # extra fallback
      when :gbl_resourceClass_sm
        # +:gbl_resourceClass_sm+ defaults to "Datasets".
        mapping = ["Datasets"] unless mapping.present?
      when :dct_title_s
        # At present, +:dct_title_s+ is provided by Hyrax, not the schema.
        mapping += resource.title.to_a
      end

      # Cast mappings to the appropriate types.
      case dfn[:type]
      when :boolean
        mapping.map! { |v| (v == "false") ? false : v.present? }
      when :integer
        mapping.map!(&:to_i)
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
end
