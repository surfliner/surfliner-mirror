# frozen_string_literal: true

Spotlight::Engine.config.exhibit_themes =
  %w[default] +
  ENV.fetch("SPOTLIGHT_THEMES") { "" }.split(",")

# ==> User model
# Note that your chosen model must include Spotlight::User mixin
# Spotlight::Engine.config.user_class = '::User'

# ==> Blacklight configuration
# Spotlight uses this upstream configuration to populate settings for the curator
# Spotlight::Engine.config.catalog_controller_class = '::CatalogController'
# Spotlight::Engine.config.default_blacklight_config = nil

# ==> Appearance configuration
# Spotlight::Engine.config.exhibit_main_navigation = [:curated_features, :browse, :about]
# Spotlight::Engine.config.resource_partials = [
#   'spotlight/resources/external_resources_form',
#   'spotlight/resources/upload/form',
#   'spotlight/resources/csv_upload/form',
#   'spotlight/resources/json_upload/form'
# ]
# Spotlight::Engine.config.external_resources_partials = []
# Spotlight::Engine.config.default_browse_index_view_type = :gallery
Spotlight::Engine.config.default_contact_email = ENV["FROM_EMAIL"]

# ==> Solr configuration
# Spotlight::Engine.config.writable_index = true
# Spotlight::Engine.config.solr_batch_size = 20
# Spotlight::Engine.config.filter_resources_by_exhibit = true
# Spotlight::Engine.config.autocomplete_search_field = 'autocomplete'
# Spotlight::Engine.config.default_autocomplete_params = { qf: 'id^1000 full_title_tesim^100 id_ng full_title_ng' }

# Solr field configurations
# Spotlight::Engine.config.solr_fields.prefix = ''.freeze
# Spotlight::Engine.config.solr_fields.boolean_suffix = '_bsi'.freeze
# Spotlight::Engine.config.solr_fields.string_suffix = '_ssim'.freeze
# Spotlight::Engine.config.solr_fields.text_suffix = '_tesim'.freeze
# Spotlight::Engine.config.resource_global_id_field = :"#{config.solr_fields.prefix}spotlight_resource_id#{config.solr_fields.string_suffix}"
# Spotlight::Engine.config.full_image_field = :full_image_url_ssm
# Spotlight::Engine.config.thumbnail_field = :thumbnail_url_ssm

# Spotlight::Engine.config.upload_fields += [
#   Spotlight::UploadFieldConfig.new(
#     field_name: :spotlight_upload_contributor_tesim,
#     label: -> { I18n.t(:"spotlight.search.fields.spotlight_upload_contributor_tesim") }
#   ),
#   Spotlight::UploadFieldConfig.new(
#     field_name: :spotlight_upload_coverage_tesim,
#     label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_coverage_tesim') }
#   ),
#   Spotlight::UploadFieldConfig.new(
#     field_name: :spotlight_upload_creator_tesim,
#     label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_creator_tesim') }
#   ),
#   Spotlight::UploadFieldConfig.new(
#     field_name: :spotlight_upload_format_tesim,
#     label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_format_tesim') }
#   ),
#   Spotlight::UploadFieldConfig.new(
#     field_name: :spotlight_upload_identifier_tesim,
#     label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_identifier_tesim') }
#   ),
#   Spotlight::UploadFieldConfig.new(
#     field_name: :spotlight_upload_language_tesim,
#     label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_language_tesim') }
#   ),
#   Spotlight::UploadFieldConfig.new(
#     field_name: :spotlight_upload_publisher_tesim,
#     label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_publisher_tesim') }
#   ),
#   Spotlight::UploadFieldConfig.new(
#     field_name: :spotlight_upload_relation_tesim,
#     label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_relation_tesim') }
#   ),
#   Spotlight::UploadFieldConfig.new(
#     field_name: :spotlight_upload_rights_tesim,
#     label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_rights_tesim') }
#   ),
#   Spotlight::UploadFieldConfig.new(
#     field_name: :spotlight_upload_source_tesim,
#     label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_source_tesim') }
#   ),
#   Spotlight::UploadFieldConfig.new(
#     field_name: :spotlight_upload_subject_tesim,
#     label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_subject_tesim') }
#   ),
#   Spotlight::UploadFieldConfig.new(
#     field_name: :spotlight_upload_type_tesim,
#     label: -> { I18n.t(:'spotlight.search.fields.spotlight_upload_type_tesim') }
#   )
# ]
# Spotlight::Engine.config.upload_title_field = nil # Spotlight::UploadFieldConfig.new(...)
# Spotlight::Engine.config.uploader_storage = :file
Spotlight::Engine.config.uploader_storage = :aws if ENV["S3_BUCKET_NAME"].present?
Spotlight::Engine.config.allowed_upload_extensions = %w[jpg jpeg png tif tiff pdf]
Spotlight::Engine.config.upload_dir = Rails.root.join("public", "uploads") unless ENV["S3_BUCKET_NAME"].present?

Spotlight::Engine.config.iiif_service = if ActiveModel::Type::Boolean.new.cast(ENV["EXTERNAL_IIIF"])
                                          Starlight::CantaloupeService
                                        else
                                          Spotlight::RiiifService
                                        end

# Spotlight::Engine.config.featured_image_thumb_size = [400, 300]
# Spotlight::Engine.config.featured_image_square_size = [400, 400]

# ==> Google Analytics integration
# Spotlight::Engine.config.analytics_provider = nil
# Spotlight::Engine.config.ga_pkcs12_key_path = nil
# Spotlight::Engine.config.ga_web_property_id = nil
# Spotlight::Engine.config.ga_email = nil
# Spotlight::Engine.config.ga_analytics_options = {}
# Spotlight::Engine.config.ga_page_analytics_options = config.ga_analytics_options.merge(limit: 5)

# ==> Sir Trevor Widget Configuration
# Spotlight::Engine.config.sir_trevor_widgets = %w(
#   Heading Text List Quote Iframe Video Oembed Rule UploadedItems Browse
#   FeaturedPages SolrDocuments SolrDocumentsCarousel SolrDocumentsEmbed
#   SolrDocumentsFeatures SolrDocumentsGrid SearchResults
# )
#
# Page configurations made available to widgets
# Spotlight::Engine.config.page_configurations = {
#   'my-local-config': ->(context) { context.my_custom_data_path(context.current_exhibit) }
# }
