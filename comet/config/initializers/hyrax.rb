# frozen_string_literal: true

require "cgi"

Hyrax.config do |config|
  # +GenericObject+ is currently hardcoded in at least the following places:
  #
  # - CometObjectPresenter (loosely)
  # - views/hyrax/base/_attribute_rows.html.erb (loosely)
  #
  # TODO: These need to be replaced with a more flexible mechanism.

  # Generate the necessary models and controllers for each M3 resource class
  # name, and define it as a Hyrax curation concern.
  #
  # This unfortunately needs to all happen up‐front in the initializer due to
  # the requirements of Rails routing.
  ::SchemaLoader.new.resource_classes.keys.filter { |class_name|
    !%i[collection file_set].include?(class_name) # remove “special” keys
  }.each do |class_name|
    model_name = class_name.to_s.camelize
    model_class = Valkyrie.config.resource_class_resolver.call(model_name)
    controller_name = "#{model_name.pluralize}Controller"
    defined_controller = "Hyrax::#{controller_name}".safe_constantize
    if !defined_controller
      controller_class = Class.new(Hyrax::ResourcesController) do
        self.curation_concern_type = model_class
      end
      Hyrax.const_set(controller_name, controller_class)
    end
    config.register_curation_concern(class_name)
  end

  config.disable_wings = true

  config.collection_model = "Hyrax::PcdmCollection"
  config.admin_set_model = "Hyrax::AdministrativeSet"

  # Register roles that are expected by your implementation.
  # @see Hyrax::RoleRegistry for additional details.
  # @note there are magical roles as defined in Hyrax::RoleRegistry::MAGIC_ROLES
  # config.register_roles do |registry|
  #   registry.add(name: 'captaining', description: 'For those that really like the front lines')
  # end

  # When an admin set is created, we need to activate a workflow.
  # The :default_active_workflow_name is the name of the workflow we will activate.
  # @see Hyrax::Configuration for additional details and defaults.
  # config.default_active_workflow_name = 'default'

  # Which RDF term should be used to relate objects to an admin set?
  # If this is a new repository, you may want to set a custom predicate term here to
  # avoid clashes if you plan to use the default (dct:isPartOf) for other relations.
  # config.admin_set_predicate = ::RDF::DC.isPartOf

  # Which RDF term should be used to relate objects to a rendering?
  # If this is a new repository, you may want to set a custom predicate term here to
  # avoid clashes if you plan to use the default (dct:hasFormat) for other relations.
  # config.rendering_predicate = ::RDF::DC.hasFormat

  # Email recipient of messages sent via the contact form
  # config.contact_email = "repo-admin@example.org"

  # Text prefacing the subject entered in the contact form
  # config.subject_prefix = "Contact form:"

  # How many notifications should be displayed on the dashboard
  # config.max_notifications_for_dashboard = 5

  # How frequently should a file be fixity checked
  # config.max_days_between_fixity_checks = 7

  # Options to control the file uploader
  # config.uploader = {
  #   limitConcurrentUploads: 6,
  #   maxNumberOfFiles: 100,
  #   maxFileSize: 500.megabytes
  # }

  # Enable displaying usage statistics in the UI
  # Defaults to false
  # Requires a Google Analytics id and OAuth2 keyfile.  See README for more info
  # config.analytics = false

  # Google Analytics tracking ID to gather usage statistics
  # config.google_analytics_id = 'UA-99999999-1'

  # Date you wish to start collecting Google Analytic statistics for
  # Leaving it blank will set the start date to when ever the file was uploaded by
  # NOTE: if you have always sent analytics to GA for downloads and page views leave this commented out
  # config.analytic_start_date = DateTime.new(2014, 9, 10)

  # Enables a link to the citations page for a work
  # Default is false
  # config.citations = false

  # Where to store tempfiles, leave blank for the system temp directory (e.g. /tmp)
  # config.temp_file_base = '/home/developer1'

  # Hostpath to be used in Endnote exports
  # config.persistent_hostpath = 'http://localhost/files/'

  # If you have ffmpeg installed and want to transcode audio and video set to true
  # config.enable_ffmpeg = false

  # Disable Hyrax NOIDs. This is really just a config switch, since we don't use
  # models that auto-mint NOIDs
  config.enable_noids = false

  # Prefix for Redis keys
  # config.redis_namespace = "hyrax"

  # Path to the file characterization tool
  # config.fits_path = "fits.sh"

  # Path to the file derivatives creation tool
  # config.libreoffice_path = "soffice"

  # Option to enable/disable full text extraction from PDFs
  # Default is true, set to false to disable full text extraction
  # config.extract_full_text = true

  # How many seconds back from the current time that we should show by default of the user's activity on the user's dashboard
  # config.activity_to_show_default_seconds_since_now = 24*60*60

  # Hyrax can integrate with Zotero's Arkivo service for automatic deposit
  # of Zotero-managed research items.
  # config.arkivo_api = false

  # Stream realtime notifications to users in the browser
  # config.realtime_notifications = true

  # Location autocomplete uses geonames to search for named regions
  # Username for connecting to geonames
  # config.geonames_username = ''

  # Should the acceptance of the licence agreement be active (checkbox), or
  # implied when the save button is pressed? Set to true for active
  # The default is true.
  # config.active_deposit_agreement_acceptance = true

  # Should work creation require file upload, or can a work be created first
  # and a file added at a later time?
  # The default is true.
  config.work_requires_files = false

  # How many rows of items should appear on the work show view?
  # The default is 10
  # config.show_work_item_rows = 10

  # Enable IIIF image service. This is required to use the
  # IIIF viewer enabled show page
  #
  # If you have run the riiif generator, an embedded riiif service
  # will be used to deliver images via IIIF. If you have not, you will
  # need to configure the following other configuration values to work
  # with your image server:
  #
  #   * iiif_image_url_builder
  #   * iiif_info_url_builder
  #   * iiif_image_compliance_level_uri
  #   * iiif_image_size_default
  #
  # Default is false
  config.iiif_image_server = true

  # Returns a URL that resolves to an image provided by a IIIF image server
  config.iiif_image_url_builder = lambda do |file_id, _base_url, size, format|
    fs = Hyrax.query_service.find_by(id: file_id)
    fid = CGI.escape(fs.file_ids.first.to_s)
    "#{ENV["IIIF_BASE_URL"]}/iiif/2/#{fid}/full/#{size}/0/default.#{format}"
  end

  # Returns a URL that resolves to an info.json file provided by a IIIF image server
  config.iiif_info_url_builder = lambda do |file_id, _base_url|
    fs = Hyrax.query_service.find_by(id: file_id)
    fid = CGI.escape(fs.file_ids.first.to_s)
    "#{ENV["IIIF_BASE_URL"]}/iiif/2/#{fid}"
  end

  # Returns a URL that indicates your IIIF image server compliance level
  # config.iiif_image_compliance_level_uri = 'http://iiif.io/api/image/2/level2.json'

  # Returns a IIIF image size default
  # config.iiif_image_size_default = '600,'

  # Fields to display in the IIIF metadata section; default is the required fields
  # config.iiif_metadata_fields = Hyrax::Forms::WorkForm.required_fields

  # Should a button with "Share my work" show on the front page to all users (even those not logged in)?
  # config.display_share_button_when_not_logged_in = true

  # The user who runs batch jobs. Update this if you aren't using emails
  # config.batch_user_key = 'batchuser@example.com'

  # The user who runs fixity check jobs. Update this if you aren't using emails
  # config.audit_user_key = 'audituser@example.com'
  #
  # The banner image. Should be 5000px wide by 1000px tall
  # config.banner_image = 'https://cloud.githubusercontent.com/assets/92044/18370978/88ecac20-75f6-11e6-8399-6536640ef695.jpg'

  # Temporary paths to hold uploads before they are ingested into FCrepo
  # These must be lambdas that return a Pathname. Can be configured separately
  #  config.upload_path = ->() { Rails.root + 'tmp' + 'uploads' }
  #  config.cache_path = ->() { Rails.root + 'tmp' + 'uploads' + 'cache' }

  # Location on local file system where derivatives will be stored
  # If you use a multi-server architecture, this MUST be a shared volume
  # config.derivatives_path = Rails.root.join('tmp', 'derivatives')

  # Should schema.org microdata be displayed?
  # config.display_microdata = true

  # What default microdata type should be used if a more appropriate
  # type can not be found in the locale file?
  # config.microdata_default_type = 'http://schema.org/CreativeWork'

  # Location on local file system where uploaded files will be staged
  # prior to being ingested into the repository or having derivatives generated.
  # If you use a multi-server architecture, this MUST be a shared volume.
  # config.working_path = Rails.root.join('tmp', 'uploads')

  # Should the media display partial render a download link?
  # config.display_media_download_link = true

  # A configuration point for changing the behavior of the license service
  #   @see Hyrax::LicenseService for implementation details
  # config.license_service_class = Hyrax::LicenseService

  # Labels for display of permission levels
  # config.permission_levels = { "View/Download" => "read", "Edit access" => "edit" }

  # Labels for permission level options used in dropdown menus
  # config.permission_options = { "Choose Access" => "none", "View/Download" => "read", "Edit" => "edit" }

  # Labels for owner permission levels
  # config.owner_permission_levels = { "Edit Access" => "edit" }

  # Path to the ffmpeg tool
  # config.ffmpeg_path = 'ffmpeg'

  # Max length of FITS messages to display in UI
  # config.fits_message_length = 5

  # ActiveJob queue to handle ingest-like jobs
  # config.ingest_queue_name = :default

  ## Attributes for the lock manager which ensures a single process/thread is mutating a ore:Aggregation at once.
  # How many times to retry to acquire the lock before raising UnableToAcquireLockError
  # config.lock_retry_count = 600 # Up to 2 minutes of trying at intervals up to 200ms
  #
  # Maximum wait time in milliseconds before retrying. Wait time is a random value between 0 and retry_delay.
  # config.lock_retry_delay = 200
  #
  # How long to hold the lock in milliseconds
  # config.lock_time_to_live = 60_000

  # use comet's valkyrie index for search
  config.query_index_from_valkyrie = false
  config.index_adapter = :comet_index

  # disable browse_everything. we may want to re-add this later,
  # or consider other mechanisms for uploading external cloud content.
  config.browse_everything = nil

  ## Register all directories which can be used to ingest from the local file
  # system.
  #
  # Any file, and only those, that is anywhere under one of the specified
  # directories can be used by CreateWithRemoteFilesActor to add local files
  # to works. Files uploaded by the user are handled separately and the
  # temporary directory for those need not be included here.
  #
  # Default value includes BrowseEverything.config['file_system'][:home] if it
  # is set, otherwise default is an empty list. You should only need to change
  # this if you have custom ingestions using CreateWithRemoteFilesActor to
  # ingest files from the file system that are not part of the BrowseEverything
  # mount point.
  #
  # config.registered_ingest_dirs = []

  ##
  # Set the system-wide virus scanner
  config.virus_scanner = Hyrax::VirusScanner

  ## Remote identifiers configuration
  # Add registrar implementations by uncommenting and adding to the hash below.
  # See app/services/hyrax/identifier/registrar.rb for the registrar interface
  # config.identifier_registrars = {}
end

Date::DATE_FORMATS[:standard] = "%m/%d/%Y"

Qa::Authorities::Local.register_subauthority("subjects", "Qa::Authorities::Local::TableBasedAuthority")
Qa::Authorities::Local.register_subauthority("languages", "Qa::Authorities::Local::TableBasedAuthority")
Qa::Authorities::Local.register_subauthority("genres", "Qa::Authorities::Local::TableBasedAuthority")

[Hyrax::CustomQueries::Navigators::CollectionMembers,

  Hyrax::CustomQueries::Navigators::ChildFileSetsNavigator,
  Hyrax::CustomQueries::Navigators::ChildWorksNavigator,
  Hyrax::CustomQueries::FindAccessControl,
  Hyrax::CustomQueries::FindCollectionsByType,
  Hyrax::CustomQueries::FindManyByAlternateIds,
  Hyrax::CustomQueries::FindIdsByModel,
  CustomQueries::FindFileMetadata,
  Hyrax::CustomQueries::FindFileMetadata].each do |handler|
  Hyrax.query_service.custom_queries.register_query_handler(handler)
end

# just to satisfy a strict type check
module Wings
  module Valkyrie
    class MetadataAdapter
    end
  end
end

Hyrax::Resource.class_eval do
  def self._hyrax_default_name_class
    Hyrax::Name
  end
end

Hyrax::Group.class_eval do
  def ==(other)
    (other.class == self.class) &&
      (name == other.name)
  end
end

class CometTransactionContainer
  extend Dry::Container::Mixin

  namespace "work_resource" do |steps|
    steps.register "add_file_sets" do
      Hyrax::Transactions::Steps::AddFileSets.new(handler: InlineUploadHandler)
    end
  end
end

module PcdmUseExtension
  GEOSHAPE_FILE = ::Valkyrie::Vocab::PCDMUseExtesion.GeoShapeFile

  ##
  # @param use [RDF::URI, Symbol]
  #
  # @return [RDF::URI]
  # @raise [ArgumentError] if no use is known for the argument
  def uri_for(use:)
    case use
    when RDF::URI
      use
    when :original_file
      Hyrax::FileMetadata::Use::ORIGINAL_FILE
    when :extracted_file
      Hyrax::FileMetadata::Use::EXTRACTED_TEXT
    when :thumbnail_file
      Hyrax::FileMetadata::Use::THUMBNAIL
    when :geoshape_file
      GEOSHAPE_FILE
    else
      raise ArgumentError, "No PCDM use is recognized for #{use}"
    end
  end
end

[Hyrax::FileMetadata::Use, Hyrax::FileMetadata::Use.singleton_class].each do |mod|
  mod.prepend PcdmUseExtension
end

Hyrax::Transactions::Container.merge(CometTransactionContainer)

Hyrax::DashboardController.sidebar_partials[:repository_content] << "hyrax/dashboard/sidebar/batch_upload"

Hyrax::Engine.routes.prepend do
  get "/collections/:id", to: "dashboard/collections#show", as: :collection
end
